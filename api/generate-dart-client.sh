#!/usr/bin/env bash
# Regenerates the Dart API client app/packages/wio_api/ from api/openapi.yaml
# with the tonik version pinned in api/codegen/pubspec.lock (D-91), and records
# the contract's SHA-256 so an app test notices a stale client (D-92).
# Needs the Dart SDK of the pinned Flutter version on PATH.
set -euo pipefail

api_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
package_dir="${api_dir}/../app/packages/wio_api"

cd "${api_dir}/codegen"
dart pub get --enforce-lockfile
rm -rf "${package_dir}"
dart run tonik --config tonik.yaml
sha256sum "${api_dir}/openapi.yaml" | cut -d' ' -f1 > "${package_dir}/CONTRACT_SHA256"
echo "Generated ${package_dir} from api/openapi.yaml"
