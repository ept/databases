ALTER TABLE movies ADD COLUMN budget INT;

ALTER TABLE ratings RENAME COLUMN votes TO num_votes;

DROP TABLE plays_role;
