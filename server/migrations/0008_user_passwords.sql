-- Owner sign-in (plan 005, D-108, D-109). Never edit after merge; add a new file (D-55).

-- Server only, never synced: the Argon2id hash of a user's password. Only owners
-- have one in M1; customers and helpers sign in by link in M6.
CREATE TABLE user_passwords (
  workspace_id CHAR(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  user_id CHAR(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  password_hash VARCHAR(255) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  changed_at DATETIME(3) NOT NULL,
  PRIMARY KEY (workspace_id, user_id),
  CONSTRAINT fk_user_passwords_workspace FOREIGN KEY (workspace_id) REFERENCES workspaces (id),
  CONSTRAINT fk_user_passwords_user FOREIGN KEY (workspace_id, user_id) REFERENCES users (workspace_id, id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;
