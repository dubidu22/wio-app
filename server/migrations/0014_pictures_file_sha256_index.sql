-- File download (plan 055, D-226). Never edit after merge; add a new file (D-55).

-- getFile looks up the pictures that point at a hash within one workspace.
CREATE INDEX ix_pictures_file ON pictures (workspace_id, file_sha256);
