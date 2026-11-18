-- Schema v1 (plan 003, D-47 to D-57). Never edit after merge; add a new file (D-55).

-- A working day at a customer (professional only).
CREATE TABLE jobs (
  id CHAR(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  workspace_id CHAR(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  customer_id CHAR(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  date DATE NOT NULL,
  agreed_minutes INT UNSIGNED NULL,
  report_sent_at DATETIME(3) NULL,
  created_at DATETIME(3) NOT NULL,
  created_by CHAR(36) CHARACTER SET ascii COLLATE ascii_bin NULL,
  updated_at DATETIME(3) NOT NULL,
  updated_by CHAR(36) CHARACTER SET ascii COLLATE ascii_bin NULL,
  revision BIGINT UNSIGNED NOT NULL,
  deleted_at DATETIME(3) NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_jobs_scope (workspace_id, id),
  UNIQUE KEY uq_jobs_customer_scope (workspace_id, customer_id, id),
  KEY ix_jobs_revision (workspace_id, revision),
  CONSTRAINT fk_jobs_workspace FOREIGN KEY (workspace_id) REFERENCES workspaces (id),
  CONSTRAINT fk_jobs_customer FOREIGN KEY (workspace_id, customer_id) REFERENCES customers (workspace_id, id),
  CONSTRAINT ck_jobs_id CHECK (id REGEXP '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$')
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;

-- Start and stop of work on a job; ended_at is null while running.
CREATE TABLE time_blocks (
  id CHAR(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  workspace_id CHAR(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  customer_id CHAR(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  job_id CHAR(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  started_at DATETIME(3) NOT NULL,
  ended_at DATETIME(3) NULL,
  created_at DATETIME(3) NOT NULL,
  created_by CHAR(36) CHARACTER SET ascii COLLATE ascii_bin NULL,
  updated_at DATETIME(3) NOT NULL,
  updated_by CHAR(36) CHARACTER SET ascii COLLATE ascii_bin NULL,
  revision BIGINT UNSIGNED NOT NULL,
  deleted_at DATETIME(3) NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_time_blocks_scope (workspace_id, id),
  UNIQUE KEY uq_time_blocks_customer_scope (workspace_id, customer_id, id),
  KEY ix_time_blocks_revision (workspace_id, revision),
  CONSTRAINT fk_time_blocks_workspace FOREIGN KEY (workspace_id) REFERENCES workspaces (id),
  CONSTRAINT fk_time_blocks_customer FOREIGN KEY (workspace_id, customer_id) REFERENCES customers (workspace_id, id),
  CONSTRAINT fk_time_blocks_job FOREIGN KEY (workspace_id, job_id) REFERENCES jobs (workspace_id, id),
  CONSTRAINT fk_time_blocks_job_customer FOREIGN KEY (workspace_id, customer_id, job_id) REFERENCES jobs (workspace_id, customer_id, id),
  CONSTRAINT ck_time_blocks_order CHECK (ended_at IS NULL OR ended_at >= started_at),
  CONSTRAINT ck_time_blocks_id CHECK (id REGEXP '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$')
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;

-- The customer confirms the hours and signs. signed_by is the user whose device took the signature, if known.
CREATE TABLE sign_offs (
  id CHAR(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  workspace_id CHAR(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  customer_id CHAR(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  job_id CHAR(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  minutes_confirmed INT UNSIGNED NOT NULL,
  signature LONGTEXT NOT NULL,
  signed_at DATETIME(3) NOT NULL,
  signed_by CHAR(36) CHARACTER SET ascii COLLATE ascii_bin NULL,
  created_at DATETIME(3) NOT NULL,
  created_by CHAR(36) CHARACTER SET ascii COLLATE ascii_bin NULL,
  updated_at DATETIME(3) NOT NULL,
  updated_by CHAR(36) CHARACTER SET ascii COLLATE ascii_bin NULL,
  revision BIGINT UNSIGNED NOT NULL,
  deleted_at DATETIME(3) NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_sign_offs_scope (workspace_id, id),
  UNIQUE KEY uq_sign_offs_customer_scope (workspace_id, customer_id, id),
  KEY ix_sign_offs_revision (workspace_id, revision),
  CONSTRAINT fk_sign_offs_workspace FOREIGN KEY (workspace_id) REFERENCES workspaces (id),
  CONSTRAINT fk_sign_offs_customer FOREIGN KEY (workspace_id, customer_id) REFERENCES customers (workspace_id, id),
  CONSTRAINT fk_sign_offs_job FOREIGN KEY (workspace_id, job_id) REFERENCES jobs (workspace_id, id),
  CONSTRAINT fk_sign_offs_job_customer FOREIGN KEY (workspace_id, customer_id, job_id) REFERENCES jobs (workspace_id, customer_id, id),
  CONSTRAINT fk_sign_offs_signed_by FOREIGN KEY (workspace_id, signed_by) REFERENCES users (workspace_id, id),
  CONSTRAINT ck_sign_offs_signature_json CHECK (JSON_VALID(signature)),
  CONSTRAINT ck_sign_offs_id CHECK (id REGEXP '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$')
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;

-- A receipt on a job: a picture and an amount in cents.
CREATE TABLE expenses (
  id CHAR(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  workspace_id CHAR(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  customer_id CHAR(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  job_id CHAR(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  picture_id CHAR(36) CHARACTER SET ascii COLLATE ascii_bin NULL,
  amount_cents INT UNSIGNED NULL,
  note VARCHAR(1000) NULL,
  created_at DATETIME(3) NOT NULL,
  created_by CHAR(36) CHARACTER SET ascii COLLATE ascii_bin NULL,
  updated_at DATETIME(3) NOT NULL,
  updated_by CHAR(36) CHARACTER SET ascii COLLATE ascii_bin NULL,
  revision BIGINT UNSIGNED NOT NULL,
  deleted_at DATETIME(3) NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_expenses_scope (workspace_id, id),
  UNIQUE KEY uq_expenses_customer_scope (workspace_id, customer_id, id),
  KEY ix_expenses_revision (workspace_id, revision),
  CONSTRAINT fk_expenses_workspace FOREIGN KEY (workspace_id) REFERENCES workspaces (id),
  CONSTRAINT fk_expenses_customer FOREIGN KEY (workspace_id, customer_id) REFERENCES customers (workspace_id, id),
  CONSTRAINT fk_expenses_job FOREIGN KEY (workspace_id, job_id) REFERENCES jobs (workspace_id, id),
  CONSTRAINT fk_expenses_job_customer FOREIGN KEY (workspace_id, customer_id, job_id) REFERENCES jobs (workspace_id, customer_id, id),
  CONSTRAINT fk_expenses_picture FOREIGN KEY (workspace_id, picture_id) REFERENCES pictures (workspace_id, id),
  CONSTRAINT fk_expenses_picture_customer FOREIGN KEY (workspace_id, customer_id, picture_id) REFERENCES pictures (workspace_id, customer_id, id),
  CONSTRAINT ck_expenses_id CHECK (id REGEXP '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$')
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;
