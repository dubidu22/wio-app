-- File download (plan 055, D-226). Never edit after merge; add a new file (D-55).

-- getFile looks up the notes whose recording is a hash within one workspace.
CREATE INDEX ix_notes_audio ON notes (workspace_id, audio_sha256);
