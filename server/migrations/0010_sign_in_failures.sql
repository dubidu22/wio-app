-- Owner sign-in (plan 005, D-113). Never edit after merge; add a new file (D-55).

-- Server only, never synced, no workspace (the e-mail may not exist): failed
-- sign-ins, as SHA-256 of the e-mail key and of the IP address, kept 24 hours
-- for the sign-in limits. The privacy notice names this table.
CREATE TABLE sign_in_failures (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  email_hash CHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  ip_hash CHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  failed_at DATETIME(3) NOT NULL,
  PRIMARY KEY (id),
  KEY ix_sign_in_failures_email (email_hash, failed_at),
  KEY ix_sign_in_failures_ip (ip_hash, failed_at),
  KEY ix_sign_in_failures_failed_at (failed_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;
