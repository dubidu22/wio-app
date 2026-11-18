-- Schema v1 (plan 003, D-47 to D-57). Never edit after merge; add a new file (D-55).

-- A word of the workspace's vocabulary (D-5). name_key is made by the server (D-51).
CREATE TABLE labels (
  id CHAR(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  workspace_id CHAR(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  name VARCHAR(100) NOT NULL,
  name_key VARCHAR(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  created_at DATETIME(3) NOT NULL,
  created_by CHAR(36) CHARACTER SET ascii COLLATE ascii_bin NULL,
  updated_at DATETIME(3) NOT NULL,
  updated_by CHAR(36) CHARACTER SET ascii COLLATE ascii_bin NULL,
  revision BIGINT UNSIGNED NOT NULL,
  deleted_at DATETIME(3) NULL,
  alive TINYINT UNSIGNED AS (IF(deleted_at IS NULL, 1, NULL)) STORED,
  PRIMARY KEY (id),
  UNIQUE KEY uq_labels_scope (workspace_id, id),
  UNIQUE KEY uq_labels_name (workspace_id, name_key, alive),
  KEY ix_labels_revision (workspace_id, revision),
  CONSTRAINT fk_labels_workspace FOREIGN KEY (workspace_id) REFERENCES workspaces (id),
  CONSTRAINT ck_labels_id CHECK (id REGEXP '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$')
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;

-- A property key of the workspace's vocabulary (D-5).
CREATE TABLE property_keys (
  id CHAR(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  workspace_id CHAR(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  name VARCHAR(100) NOT NULL,
  name_key VARCHAR(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  unit VARCHAR(32) NULL,
  created_at DATETIME(3) NOT NULL,
  created_by CHAR(36) CHARACTER SET ascii COLLATE ascii_bin NULL,
  updated_at DATETIME(3) NOT NULL,
  updated_by CHAR(36) CHARACTER SET ascii COLLATE ascii_bin NULL,
  revision BIGINT UNSIGNED NOT NULL,
  deleted_at DATETIME(3) NULL,
  alive TINYINT UNSIGNED AS (IF(deleted_at IS NULL, 1, NULL)) STORED,
  PRIMARY KEY (id),
  UNIQUE KEY uq_property_keys_scope (workspace_id, id),
  UNIQUE KEY uq_property_keys_name (workspace_id, name_key, alive),
  KEY ix_property_keys_revision (workspace_id, revision),
  CONSTRAINT fk_property_keys_workspace FOREIGN KEY (workspace_id) REFERENCES workspaces (id),
  CONSTRAINT ck_property_keys_id CHECK (id REGEXP '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$')
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;

-- A label on an entry, room, fixture or picture (D-50); customer_id is the subject's.
CREATE TABLE entity_labels (
  id CHAR(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  workspace_id CHAR(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  customer_id CHAR(36) CHARACTER SET ascii COLLATE ascii_bin NULL,
  entity_type VARCHAR(16) NOT NULL,
  entity_id CHAR(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  label_id CHAR(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  created_at DATETIME(3) NOT NULL,
  created_by CHAR(36) CHARACTER SET ascii COLLATE ascii_bin NULL,
  updated_at DATETIME(3) NOT NULL,
  updated_by CHAR(36) CHARACTER SET ascii COLLATE ascii_bin NULL,
  revision BIGINT UNSIGNED NOT NULL,
  deleted_at DATETIME(3) NULL,
  alive TINYINT UNSIGNED AS (IF(deleted_at IS NULL, 1, NULL)) STORED,
  PRIMARY KEY (id),
  UNIQUE KEY uq_entity_labels_scope (workspace_id, id),
  UNIQUE KEY uq_entity_labels_customer_scope (workspace_id, customer_id, id),
  UNIQUE KEY uq_entity_labels_link (workspace_id, entity_type, entity_id, label_id, alive),
  KEY ix_entity_labels_revision (workspace_id, revision),
  CONSTRAINT fk_entity_labels_workspace FOREIGN KEY (workspace_id) REFERENCES workspaces (id),
  CONSTRAINT fk_entity_labels_customer FOREIGN KEY (workspace_id, customer_id) REFERENCES customers (workspace_id, id),
  CONSTRAINT fk_entity_labels_label FOREIGN KEY (workspace_id, label_id) REFERENCES labels (workspace_id, id),
  CONSTRAINT ck_entity_labels_type CHECK (entity_type IN ('entry', 'room', 'fixture', 'picture')),
  CONSTRAINT ck_entity_labels_id CHECK (id REGEXP '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$')
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;

-- One property value of an entry, room, fixture or picture (D-50); customer_id is the subject's.
CREATE TABLE entity_properties (
  id CHAR(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  workspace_id CHAR(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  customer_id CHAR(36) CHARACTER SET ascii COLLATE ascii_bin NULL,
  entity_type VARCHAR(16) NOT NULL,
  entity_id CHAR(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  key_id CHAR(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  value_text VARCHAR(1000) NULL,
  value_number DECIMAL(20,6) NULL,
  created_at DATETIME(3) NOT NULL,
  created_by CHAR(36) CHARACTER SET ascii COLLATE ascii_bin NULL,
  updated_at DATETIME(3) NOT NULL,
  updated_by CHAR(36) CHARACTER SET ascii COLLATE ascii_bin NULL,
  revision BIGINT UNSIGNED NOT NULL,
  deleted_at DATETIME(3) NULL,
  alive TINYINT UNSIGNED AS (IF(deleted_at IS NULL, 1, NULL)) STORED,
  PRIMARY KEY (id),
  UNIQUE KEY uq_entity_properties_scope (workspace_id, id),
  UNIQUE KEY uq_entity_properties_customer_scope (workspace_id, customer_id, id),
  UNIQUE KEY uq_entity_properties_link (workspace_id, entity_type, entity_id, key_id, alive),
  KEY ix_entity_properties_revision (workspace_id, revision),
  CONSTRAINT fk_entity_properties_workspace FOREIGN KEY (workspace_id) REFERENCES workspaces (id),
  CONSTRAINT fk_entity_properties_customer FOREIGN KEY (workspace_id, customer_id) REFERENCES customers (workspace_id, id),
  CONSTRAINT fk_entity_properties_key FOREIGN KEY (workspace_id, key_id) REFERENCES property_keys (workspace_id, id),
  CONSTRAINT ck_entity_properties_type CHECK (entity_type IN ('entry', 'room', 'fixture', 'picture')),
  CONSTRAINT ck_entity_properties_one_value CHECK (value_text IS NULL OR value_number IS NULL),
  CONSTRAINT ck_entity_properties_id CHECK (id REGEXP '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$')
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;
