-- Adding a column to an existing table
ALTER TABLE movies ADD COLUMN budget INT;

-- Renaming an existing column
ALTER TABLE ratings RENAME COLUMN votes TO num_votes;

-- Deleting a table entirely
DROP TABLE plays_role;
