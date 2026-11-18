-- Owner sign-in (plan 005, D-114). Never edit after merge; add a new file (D-55).

-- Sign-in looks up owners by e-mail across workspaces; the unique key starts
-- with workspace_id, so it cannot serve that lookup.
CREATE INDEX ix_users_email_key ON users (email_key);
