-- Sync push (plan 006, D-173). Never edit after merge; add a new file (D-55).

-- Server only, never synced: the revision and change that last wrote each
-- field of each record. A pushed field that was written after the change's
-- base_revision with another value is a conflict (KB sync.md).
CREATE TABLE field_versions (
  workspace_id CHAR(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  entity VARCHAR(32) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  entity_id CHAR(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  field VARCHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  revision BIGINT UNSIGNED NOT NULL,
  change_id CHAR(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  PRIMARY KEY (workspace_id, entity, entity_id, field),
  CONSTRAINT fk_field_versions_workspace FOREIGN KEY (workspace_id) REFERENCES workspaces (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;
