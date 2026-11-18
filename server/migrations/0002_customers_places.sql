-- Schema v1 (plan 003, D-47 to D-57). Never edit after merge; add a new file (D-55).

-- A household served (professional workspaces only).
CREATE TABLE customers (
  id CHAR(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  workspace_id CHAR(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  name VARCHAR(200) NULL,
  contact LONGTEXT NULL,
  external_ref VARCHAR(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL,
  created_at DATETIME(3) NOT NULL,
  created_by CHAR(36) CHARACTER SET ascii COLLATE ascii_bin NULL,
  updated_at DATETIME(3) NOT NULL,
  updated_by CHAR(36) CHARACTER SET ascii COLLATE ascii_bin NULL,
  revision BIGINT UNSIGNED NOT NULL,
  deleted_at DATETIME(3) NULL,
  alive TINYINT UNSIGNED AS (IF(deleted_at IS NULL, 1, NULL)) STORED,
  PRIMARY KEY (id),
  UNIQUE KEY uq_customers_scope (workspace_id, id),
  UNIQUE KEY uq_customers_external_ref (workspace_id, external_ref, alive),
  KEY ix_customers_revision (workspace_id, revision),
  CONSTRAINT fk_customers_workspace FOREIGN KEY (workspace_id) REFERENCES workspaces (id),
  CONSTRAINT ck_customers_contact_json CHECK (contact IS NULL OR JSON_VALID(contact)),
  CONSTRAINT ck_customers_id CHECK (id REGEXP '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$')
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;

-- Users of role customer or helper belong to one customer of the same workspace.
ALTER TABLE users
  ADD CONSTRAINT fk_users_customer FOREIGN KEY (workspace_id, customer_id) REFERENCES customers (workspace_id, id);

-- An address; a move has two. customer_id is null in personal workspaces.
CREATE TABLE sites (
  id CHAR(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  workspace_id CHAR(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  customer_id CHAR(36) CHARACTER SET ascii COLLATE ascii_bin NULL,
  name VARCHAR(200) NULL,
  address VARCHAR(500) NULL,
  created_at DATETIME(3) NOT NULL,
  created_by CHAR(36) CHARACTER SET ascii COLLATE ascii_bin NULL,
  updated_at DATETIME(3) NOT NULL,
  updated_by CHAR(36) CHARACTER SET ascii COLLATE ascii_bin NULL,
  revision BIGINT UNSIGNED NOT NULL,
  deleted_at DATETIME(3) NULL,
  no_customer TINYINT UNSIGNED AS (customer_id <=> NULL) STORED,
  PRIMARY KEY (id),
  UNIQUE KEY uq_sites_scope (workspace_id, id),
  UNIQUE KEY uq_sites_customer_scope (workspace_id, customer_id, id),
  UNIQUE KEY uq_sites_no_customer_scope (workspace_id, no_customer, id),
  KEY ix_sites_revision (workspace_id, revision),
  CONSTRAINT fk_sites_workspace FOREIGN KEY (workspace_id) REFERENCES workspaces (id),
  CONSTRAINT fk_sites_customer FOREIGN KEY (workspace_id, customer_id) REFERENCES customers (workspace_id, id),
  CONSTRAINT ck_sites_id CHECK (id REGEXP '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$')
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;

-- A room at a site. outline: corner points in cm, clockwise from top left.
CREATE TABLE rooms (
  id CHAR(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  workspace_id CHAR(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  customer_id CHAR(36) CHARACTER SET ascii COLLATE ascii_bin NULL,
  site_id CHAR(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  name VARCHAR(200) NULL,
  outline LONGTEXT NULL,
  height_cm INT UNSIGNED NULL,
  created_at DATETIME(3) NOT NULL,
  created_by CHAR(36) CHARACTER SET ascii COLLATE ascii_bin NULL,
  updated_at DATETIME(3) NOT NULL,
  updated_by CHAR(36) CHARACTER SET ascii COLLATE ascii_bin NULL,
  revision BIGINT UNSIGNED NOT NULL,
  deleted_at DATETIME(3) NULL,
  no_customer TINYINT UNSIGNED AS (customer_id <=> NULL) STORED,
  PRIMARY KEY (id),
  UNIQUE KEY uq_rooms_scope (workspace_id, id),
  UNIQUE KEY uq_rooms_customer_scope (workspace_id, customer_id, id),
  UNIQUE KEY uq_rooms_no_customer_scope (workspace_id, no_customer, id),
  UNIQUE KEY uq_rooms_site_scope (workspace_id, site_id, id),
  KEY ix_rooms_revision (workspace_id, revision),
  CONSTRAINT fk_rooms_workspace FOREIGN KEY (workspace_id) REFERENCES workspaces (id),
  CONSTRAINT fk_rooms_customer FOREIGN KEY (workspace_id, customer_id) REFERENCES customers (workspace_id, id),
  CONSTRAINT fk_rooms_site FOREIGN KEY (workspace_id, site_id) REFERENCES sites (workspace_id, id),
  CONSTRAINT fk_rooms_site_customer FOREIGN KEY (workspace_id, customer_id, site_id) REFERENCES sites (workspace_id, customer_id, id),
  CONSTRAINT fk_rooms_site_no_customer FOREIGN KEY (workspace_id, no_customer, site_id) REFERENCES sites (workspace_id, no_customer, id),
  CONSTRAINT ck_rooms_outline_json CHECK (outline IS NULL OR JSON_VALID(outline)),
  CONSTRAINT ck_rooms_id CHECK (id REGEXP '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$')
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;

-- A door or window in a wall of a room.
CREATE TABLE openings (
  id CHAR(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  workspace_id CHAR(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  customer_id CHAR(36) CHARACTER SET ascii COLLATE ascii_bin NULL,
  room_id CHAR(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  kind VARCHAR(16) NOT NULL,
  wall_index SMALLINT UNSIGNED NOT NULL,
  offset_cm INT UNSIGNED NOT NULL,
  width_cm INT UNSIGNED NOT NULL,
  height_cm INT UNSIGNED NULL,
  created_at DATETIME(3) NOT NULL,
  created_by CHAR(36) CHARACTER SET ascii COLLATE ascii_bin NULL,
  updated_at DATETIME(3) NOT NULL,
  updated_by CHAR(36) CHARACTER SET ascii COLLATE ascii_bin NULL,
  revision BIGINT UNSIGNED NOT NULL,
  deleted_at DATETIME(3) NULL,
  no_customer TINYINT UNSIGNED AS (customer_id <=> NULL) STORED,
  PRIMARY KEY (id),
  UNIQUE KEY uq_openings_scope (workspace_id, id),
  UNIQUE KEY uq_openings_customer_scope (workspace_id, customer_id, id),
  KEY ix_openings_revision (workspace_id, revision),
  CONSTRAINT fk_openings_workspace FOREIGN KEY (workspace_id) REFERENCES workspaces (id),
  CONSTRAINT fk_openings_customer FOREIGN KEY (workspace_id, customer_id) REFERENCES customers (workspace_id, id),
  CONSTRAINT fk_openings_room FOREIGN KEY (workspace_id, room_id) REFERENCES rooms (workspace_id, id),
  CONSTRAINT fk_openings_room_customer FOREIGN KEY (workspace_id, customer_id, room_id) REFERENCES rooms (workspace_id, customer_id, id),
  CONSTRAINT fk_openings_room_no_customer FOREIGN KEY (workspace_id, no_customer, room_id) REFERENCES rooms (workspace_id, no_customer, id),
  CONSTRAINT ck_openings_kind CHECK (kind IN ('door', 'window')),
  CONSTRAINT ck_openings_id CHECK (id REGEXP '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$')
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;

-- Anything in a room that holds entries. levels: list of {height_cm, compartments}, from the bottom.
CREATE TABLE fixtures (
  id CHAR(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  workspace_id CHAR(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  customer_id CHAR(36) CHARACTER SET ascii COLLATE ascii_bin NULL,
  room_id CHAR(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  name VARCHAR(200) NULL,
  x_cm INT NOT NULL DEFAULT 0,
  y_cm INT NOT NULL DEFAULT 0,
  rotation_deg SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  width_cm INT UNSIGNED NULL,
  depth_cm INT UNSIGNED NULL,
  height_cm INT UNSIGNED NULL,
  levels LONGTEXT NULL,
  created_at DATETIME(3) NOT NULL,
  created_by CHAR(36) CHARACTER SET ascii COLLATE ascii_bin NULL,
  updated_at DATETIME(3) NOT NULL,
  updated_by CHAR(36) CHARACTER SET ascii COLLATE ascii_bin NULL,
  revision BIGINT UNSIGNED NOT NULL,
  deleted_at DATETIME(3) NULL,
  no_customer TINYINT UNSIGNED AS (customer_id <=> NULL) STORED,
  PRIMARY KEY (id),
  UNIQUE KEY uq_fixtures_scope (workspace_id, id),
  UNIQUE KEY uq_fixtures_customer_scope (workspace_id, customer_id, id),
  UNIQUE KEY uq_fixtures_room_scope (workspace_id, room_id, id),
  KEY ix_fixtures_revision (workspace_id, revision),
  CONSTRAINT fk_fixtures_workspace FOREIGN KEY (workspace_id) REFERENCES workspaces (id),
  CONSTRAINT fk_fixtures_customer FOREIGN KEY (workspace_id, customer_id) REFERENCES customers (workspace_id, id),
  CONSTRAINT fk_fixtures_room FOREIGN KEY (workspace_id, room_id) REFERENCES rooms (workspace_id, id),
  CONSTRAINT fk_fixtures_room_customer FOREIGN KEY (workspace_id, customer_id, room_id) REFERENCES rooms (workspace_id, customer_id, id),
  CONSTRAINT fk_fixtures_room_no_customer FOREIGN KEY (workspace_id, no_customer, room_id) REFERENCES rooms (workspace_id, no_customer, id),
  CONSTRAINT ck_fixtures_rotation CHECK (rotation_deg < 360),
  CONSTRAINT ck_fixtures_levels_json CHECK (levels IS NULL OR JSON_VALID(levels)),
  CONSTRAINT ck_fixtures_id CHECK (id REGEXP '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$')
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;
