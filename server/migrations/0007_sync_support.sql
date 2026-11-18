-- Schema v1 (plan 003, D-47 to D-57). Never edit after merge; add a new file (D-55).

-- A value that lost a same-field conflict (sync.md), kept for the owner to see.
CREATE TABLE conflicts (
  id CHAR(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  workspace_id CHAR(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  customer_id CHAR(36) CHARACTER SET ascii COLLATE ascii_bin NULL,
  entity VARCHAR(32) NOT NULL,
  entity_id CHAR(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  field VARCHAR(64) NOT NULL,
  lost_value LONGTEXT NULL,
  lost_change_id CHAR(36) CHARACTER SET ascii COLLATE ascii_bin NULL,
  won_revision BIGINT UNSIGNED NOT NULL,
  created_at DATETIME(3) NOT NULL,
  created_by CHAR(36) CHARACTER SET ascii COLLATE ascii_bin NULL,
  updated_at DATETIME(3) NOT NULL,
  updated_by CHAR(36) CHARACTER SET ascii COLLATE ascii_bin NULL,
  revision BIGINT UNSIGNED NOT NULL,
  deleted_at DATETIME(3) NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_conflicts_scope (workspace_id, id),
  UNIQUE KEY uq_conflicts_customer_scope (workspace_id, customer_id, id),
  KEY ix_conflicts_revision (workspace_id, revision),
  CONSTRAINT fk_conflicts_workspace FOREIGN KEY (workspace_id) REFERENCES workspaces (id),
  CONSTRAINT fk_conflicts_customer FOREIGN KEY (workspace_id, customer_id) REFERENCES customers (workspace_id, id),
  KEY ix_conflicts_record (workspace_id, entity, entity_id),
  CONSTRAINT ck_conflicts_entity CHECK (entity IN ('workspaces', 'users', 'customers', 'sites', 'rooms', 'openings', 'fixtures', 'labels', 'property_keys', 'entity_labels', 'entity_properties', 'entries', 'place_history', 'pictures', 'notes', 'jobs', 'time_blocks', 'sign_offs', 'expenses')),
  CONSTRAINT ck_conflicts_lost_value_json CHECK (lost_value IS NULL OR JSON_VALID(lost_value)),
  CONSTRAINT ck_conflicts_id CHECK (id REGEXP '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$')
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;
