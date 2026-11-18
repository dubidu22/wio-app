-- Sync push (plan 006, D-172). Never edit after merge; add a new file (D-55).

-- Server only, never synced: the answer to every pushed change_id, so a retry
-- gets the same answer and is never applied twice. Written in the change's own
-- transaction (a rejection in a transaction of its own). Rows older than 180
-- days are deleted during push.
CREATE TABLE applied_changes (
  workspace_id CHAR(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  change_id CHAR(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  device_id CHAR(36) CHARACTER SET ascii COLLATE ascii_bin NULL,
  payload_sha256 CHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  status VARCHAR(16) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  revision BIGINT UNSIGNED NULL,
  reason VARCHAR(64) CHARACTER SET ascii COLLATE ascii_bin NULL,
  existing_id CHAR(36) CHARACTER SET ascii COLLATE ascii_bin NULL,
  created_at DATETIME(3) NOT NULL,
  PRIMARY KEY (workspace_id, change_id),
  KEY ix_applied_changes_created_at (created_at),
  CONSTRAINT fk_applied_changes_workspace FOREIGN KEY (workspace_id) REFERENCES workspaces (id),
  CONSTRAINT ck_applied_changes_status CHECK (status IN ('applied', 'merged', 'rejected')),
  CONSTRAINT ck_applied_changes_payload_sha256 CHECK (payload_sha256 REGEXP '^[0-9a-f]{64}$')
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;
