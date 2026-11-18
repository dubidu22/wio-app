-- Schema v1 (plan 003, D-47 to D-57). Never edit after merge; add a new file (D-55).

-- A personal or professional space; every other record belongs to one (D-25).
CREATE TABLE workspaces (
  id CHAR(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  name VARCHAR(200) NULL,
  plan VARCHAR(16) NOT NULL,
  created_at DATETIME(3) NOT NULL,
  created_by CHAR(36) CHARACTER SET ascii COLLATE ascii_bin NULL,
  updated_at DATETIME(3) NOT NULL,
  updated_by CHAR(36) CHARACTER SET ascii COLLATE ascii_bin NULL,
  revision BIGINT UNSIGNED NOT NULL,
  deleted_at DATETIME(3) NULL,
  PRIMARY KEY (id),
  KEY ix_workspaces_revision (id, revision),
  CONSTRAINT ck_workspaces_plan CHECK (plan IN ('personal', 'professional')),
  CONSTRAINT ck_workspaces_id CHECK (id REGEXP '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$')
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;

-- Server only, not synced: the last revision handed out per workspace (D-52).
CREATE TABLE workspace_counters (
  workspace_id CHAR(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  last_revision BIGINT UNSIGNED NOT NULL DEFAULT 0,
  PRIMARY KEY (workspace_id),
  CONSTRAINT fk_workspace_counters_workspace FOREIGN KEY (workspace_id) REFERENCES workspaces (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;

-- A person with a role in one workspace (D-13). The customer foreign key is added in 0002.
CREATE TABLE users (
  id CHAR(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  workspace_id CHAR(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  customer_id CHAR(36) CHARACTER SET ascii COLLATE ascii_bin NULL,
  role VARCHAR(16) NOT NULL,
  display_name VARCHAR(200) NULL,
  email VARCHAR(254) NULL,
  email_key VARCHAR(508) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL,
  expires_at DATETIME(3) NULL,
  created_at DATETIME(3) NOT NULL,
  created_by CHAR(36) CHARACTER SET ascii COLLATE ascii_bin NULL,
  updated_at DATETIME(3) NOT NULL,
  updated_by CHAR(36) CHARACTER SET ascii COLLATE ascii_bin NULL,
  revision BIGINT UNSIGNED NOT NULL,
  deleted_at DATETIME(3) NULL,
  alive TINYINT UNSIGNED AS (IF(deleted_at IS NULL, 1, NULL)) STORED,
  PRIMARY KEY (id),
  UNIQUE KEY uq_users_scope (workspace_id, id),
  UNIQUE KEY uq_users_customer_scope (workspace_id, customer_id, id),
  UNIQUE KEY uq_users_email (workspace_id, email_key, alive),
  KEY ix_users_revision (workspace_id, revision),
  CONSTRAINT fk_users_workspace FOREIGN KEY (workspace_id) REFERENCES workspaces (id),
  CONSTRAINT ck_users_role CHECK (role IN ('owner', 'customer', 'helper')),
  CONSTRAINT ck_users_role_customer CHECK ((role = 'owner') = (customer_id IS NULL)),
  CONSTRAINT ck_users_helper_expires CHECK (role <> 'helper' OR expires_at IS NOT NULL),
  CONSTRAINT ck_users_email_key CHECK ((email IS NULL) = (email_key IS NULL)),
  CONSTRAINT ck_users_id CHECK (id REGEXP '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$')
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;
