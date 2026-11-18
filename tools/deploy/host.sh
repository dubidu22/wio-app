#!/usr/bin/env bash
# Runs ON the hosting, piped over SSH by deploy.sh (plan 010, D-158, D-159):
#   ssh host bash -s -- COMMAND DEPLOY_PATH [ARGS...] < host.sh
# Data a command needs (tarball, config, password) comes as a file that
# deploy.sh uploaded first, never on the command line.
#
# Layout under DEPLOY_PATH:
#   releases/<sha>/        one per deploy
#   current -> releases/<sha>
#   web/                   the subdomain's document root (a real directory):
#                          index.php runs the release `current` points to,
#                          .htaccess and .user.ini are copied from it
#   previous               the sha that was current before the last switch
#                          (the rollback target)
#   shared/config.php      host config (D-161), mode 0600
#   incoming/              uploads waiting to be used, removed after use
set -euo pipefail

command="${1:?usage: host.sh COMMAND DEPLOY_PATH [ARGS...]}"
root="${2:?usage: host.sh COMMAND DEPLOY_PATH [ARGS...]}"
shift 2
php="${WIO_PHP_CLI:-php}"

fail() {
  echo "host: $*" >&2
  exit 1
}

valid_sha() {
  [[ "$1" =~ ^[0-9a-f]{7,40}$ ]] || fail "not a commit sha: $1"
}

current_sha() {
  if [[ -L "$root/current" ]]; then
    basename "$(readlink "$root/current")"
  fi
}

# go_live SHA: points `current` at the release (atomic rename) and refreshes
# web/. PHP caches realpath() results for up to realpath_cache_ttl, so a
# symlinked document root could keep serving the old release for minutes;
# web/index.php resolves `current` with readlink(), which is not cached.
go_live() {
  local sha="$1" public="$root/releases/$1/public" file
  ln -sfn "releases/$sha" "$root/current.next"
  mv -T -- "$root/current.next" "$root/current"
  mkdir -p "$root/web"
  for file in .htaccess .user.ini; do
    if [[ -f "$public/$file" ]]; then
      cp -- "$public/$file" "$root/web/$file.next"
      mv -f -- "$root/web/$file.next" "$root/web/$file"
    else
      rm -f -- "$root/web/$file"
    fi
  done
  cat > "$root/web/index.php.next" << 'PHP'
<?php

// Written by the deploy (D-159): runs the live release. readlink() is not
// cached like realpath(), so a release switch counts from the next request.
$release = readlink(__DIR__ . '/../current');
if ($release === false) {
    http_response_code(503);
    exit;
}
require __DIR__ . '/../' . $release . '/public/index.php';
PHP
  mv -f -- "$root/web/index.php.next" "$root/web/index.php"
}

case "$command" in
  prepare)
    # Creates the layout. Prints the PHP version, so a wrong CLI shows early.
    mkdir -p "$root/releases" "$root/shared" "$root/incoming" "$root/web"
    chmod 700 "$root/shared" "$root/incoming"
    "$php" -r 'echo "php ", PHP_VERSION, PHP_EOL;'
    ;;

  unpack)
    # unpack ROOT SHA: incoming/<sha>.tar.gz -> releases/<sha>, linked config.
    sha="${1:?sha}"
    valid_sha "$sha"
    tarball="$root/incoming/$sha.tar.gz"
    [[ -f "$tarball" ]] || fail "no upload at $tarball"
    [[ "$(current_sha)" != "$sha" ]] || fail "release $sha is live; deploy a new commit or roll back"
    release="$root/releases/$sha"
    if [[ -d "$release" ]]; then
      rm -rf -- "${release:?}"
    fi
    mkdir -p "$release"
    tar -xzf "$tarball" -C "$release"
    rm -f -- "$tarball"
    ln -sfn ../../shared/config.php "$release/config.php"
    echo "unpacked $sha"
    ;;

  config)
    # config ROOT: incoming/config.php -> shared/config.php (0600, atomic).
    incoming="$root/incoming/config.php"
    [[ -f "$incoming" ]] || fail "no config upload"
    chmod 600 "$incoming"
    "$php" -l "$incoming" > /dev/null || fail "config.php does not parse"
    mv -f -- "$incoming" "$root/shared/config.php"
    echo "config written"
    ;;

  check)
    # check ROOT SHA: H1 to H3 of plan 010, run with the new release's code.
    sha="${1:?sha}"
    valid_sha "$sha"
    release="$root/releases/$sha"
    cd "$release"
    # shellcheck disable=SC2016 # PHP code, expanded by PHP
    "$php" -r '
      $ok = true;
      echo "H1 php ", PHP_VERSION, PHP_EOL;
      if (PHP_MAJOR_VERSION !== 8 || PHP_MINOR_VERSION !== 3) { echo "H1 FAIL: PHP 8.3 needed", PHP_EOL; $ok = false; }
      foreach (["intl", "sodium", "pdo_mysql", "mbstring", "json"] as $ext) {
          if (!extension_loaded($ext)) { echo "H1 FAIL: extension $ext missing", PHP_EOL; $ok = false; }
      }
      if (!defined("PASSWORD_ARGON2ID")) {
          echo "H2 FAIL: PASSWORD_ARGON2ID is not defined", PHP_EOL; $ok = false;
      } else {
          $t = hrtime(true);
          password_hash(bin2hex(random_bytes(16)), PASSWORD_ARGON2ID);
          $s = (hrtime(true) - $t) / 1e9;
          printf("H2 argon2id hash %.3f s%s", $s, PHP_EOL);
          if ($s >= 0.5) { echo "H2 FAIL: slower than 0.5 s", PHP_EOL; $ok = false; }
      }
      exit($ok ? 0 : 1);
    '
    # H3: Composer platform check of the release (extensions, PHP version).
    "$php" -r 'require "vendor/composer/platform_check.php"; echo "H3 composer platform ok", PHP_EOL;'
    ;;

  migrate)
    # migrate ROOT SHA: D-158, before the switch.
    sha="${1:?sha}"
    valid_sha "$sha"
    "$php" "$root/releases/$sha/bin/migrate"
    ;;

  switch)
    # switch ROOT SHA: atomic symlink swap; remembers the previous release.
    sha="${1:?sha}"
    valid_sha "$sha"
    [[ -d "$root/releases/$sha" ]] || fail "no release $sha"
    old="$(current_sha)"
    if [[ -n "$old" && "$old" != "$sha" ]]; then
      echo "$old" > "$root/previous"
    fi
    go_live "$sha"
    echo "current -> $sha (was ${old:-none})"
    ;;

  restore)
    # restore ROOT SHA [PREVIOUS]: after a failed smoke test, makes SHA live
    # again and puts back the previous marker from before the deploy.
    sha="${1:?sha}"
    valid_sha "$sha"
    before="${2:-}"
    [[ -d "$root/releases/$sha" ]] || fail "no release $sha"
    go_live "$sha"
    if [[ -n "$before" ]]; then
      valid_sha "$before"
      echo "$before" > "$root/previous"
    else
      rm -f -- "$root/previous"
    fi
    echo "current -> $sha (restored)"
    ;;

  live)
    # live ROOT: prints the sha that is live now, if any.
    current_sha
    ;;

  previous)
    # previous ROOT: prints the sha to roll back to, if any.
    if [[ -f "$root/previous" ]]; then
      cat "$root/previous"
    fi
    ;;

  prune)
    # prune ROOT KEEP: removes all but the newest KEEP releases; never the
    # current or the previous one.
    keep="${1:?keep}"
    keepers=("$(current_sha)")
    if [[ -f "$root/previous" ]]; then
      keepers+=("$(cat "$root/previous")")
    fi
    count=0
    while IFS= read -r dir; do
      name="$(basename "$dir")"
      count=$((count + 1))
      skip=false
      for k in "${keepers[@]}"; do
        [[ "$k" == "$name" ]] && skip=true
      done
      if [[ "$skip" == false && "$count" -gt "$keep" ]]; then
        rm -rf -- "${root:?}/releases/${name:?}"
        echo "pruned $name"
      fi
    done < <(ls -1dt "$root"/releases/*/ 2> /dev/null)
    ;;

  smoke-owner)
    # smoke-owner ROOT EMAIL: makes sure the staging smoke owner (D-162)
    # exists with the password in incoming/smoke-password: creates it the
    # first time, sets the password otherwise (so a rotated secret works and a
    # second run never makes a second workspace). The upload is removed.
    email="${1:?email}"
    secret="$root/incoming/smoke-password"
    [[ -f "$secret" ]] || fail "no smoke password upload"
    cd "$root/current"
    # shellcheck disable=SC2016 # PHP code, expanded by PHP
    owners="$(WIO_SMOKE_EMAIL="$email" "$php" -r '
      require "vendor/autoload.php";
      Wio\Config\HostConfig::load("config.php");
      $sql = new PDO((string) getenv("WIO_DB_DSN"), (string) getenv("WIO_DB_USER"), (string) getenv("WIO_DB_PASSWORD"),
          [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);
      $q = $sql->prepare("SELECT COUNT(*) FROM users WHERE email_key = ? AND role = \x27owner\x27 AND deleted_at IS NULL");
      $q->execute([Wio\Schema\NameKey::of((string) getenv("WIO_SMOKE_EMAIL"))]);
      echo (int) $q->fetchColumn();
    ')"
    status=0
    if [[ "$owners" == 0 ]]; then
      "$php" bin/create-owner --workspace-name=Rauchtest --plan=personal \
        --email="$email" --display-name=Rauchtest < "$secret" || status=$?
    else
      "$php" bin/set-owner-password --email="$email" < "$secret" || status=$?
    fi
    rm -f -- "$secret"
    exit "$status"
    ;;

  ip-check)
    # ip-check ROOT EMAIL: S4 of plan 010. The failed sign-in for EMAIL must
    # have stored the hash of the address this SSH connection comes from;
    # its rows are deleted afterwards.
    email="${1:?email}"
    client="${SSH_CLIENT%% *}"
    [[ -n "$client" ]] || fail "SSH_CLIENT is not set"
    cd "$root/current"
    # shellcheck disable=SC2016 # PHP code, expanded by PHP
    WIO_SMOKE_EMAIL="$email" WIO_SMOKE_CLIENT="$client" "$php" -r '
      require "vendor/autoload.php";
      Wio\Config\HostConfig::load("config.php");
      $sql = new PDO((string) getenv("WIO_DB_DSN"), (string) getenv("WIO_DB_USER"), (string) getenv("WIO_DB_PASSWORD"),
          [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);
      $emailHash = Wio\Auth\SignInLimiter::emailHash((string) getenv("WIO_SMOKE_EMAIL"));
      $expected = Wio\Auth\SignInLimiter::ipHash((string) getenv("WIO_SMOKE_CLIENT"));
      $q = $sql->prepare("SELECT ip_hash FROM sign_in_failures WHERE email_hash = ?");
      $q->execute([$emailHash]);
      $seen = $q->fetchAll(PDO::FETCH_COLUMN);
      $sql->prepare("DELETE FROM sign_in_failures WHERE email_hash = ?")->execute([$emailHash]);
      if ($seen === []) { echo "S4 FAIL: no failed sign-in stored", PHP_EOL; exit(1); }
      foreach ($seen as $hash) {
          if ($hash !== $expected) { echo "S4 FAIL: REMOTE_ADDR is not the client address (proxy?)", PHP_EOL; exit(1); }
      }
      echo "S4 REMOTE_ADDR is the client address", PHP_EOL;
    '
    ;;

  *)
    fail "unknown command $command"
    ;;
esac
