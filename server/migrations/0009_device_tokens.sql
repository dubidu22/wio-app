-- Owner sign-in (plan 005, D-110, D-111). Never edit after merge; add a new file (D-55).

-- Server only, never synced: one row per signed-in device. Only the SHA-256 of
-- the token is kept; sign-out and revoke delete the row.
CREATE TABLE device_tokens (
  id CHAR(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  workspace_id CHAR(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  user_id CHAR(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  token_hash CHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  device_name VARCHAR(100) NOT NULL,
  created_at DATETIME(3) NOT NULL,
  last_used_at DATETIME(3) NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_device_tokens_token_hash (token_hash),
  KEY ix_device_tokens_user (workspace_id, user_id),
  CONSTRAINT fk_device_tokens_workspace FOREIGN KEY (workspace_id) REFERENCES workspaces (id),
  CONSTRAINT fk_device_tokens_user FOREIGN KEY (workspace_id, user_id) REFERENCES users (workspace_id, id),
  CONSTRAINT ck_device_tokens_token_hash CHECK (token_hash REGEXP '^[0-9a-f]{64}$'),
  CONSTRAINT ck_device_tokens_id CHECK (id REGEXP '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$')
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;
