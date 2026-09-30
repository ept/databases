CREATE TABLE series(
  series_id INT PRIMARY KEY,
  name      TEXT
);

ALTER TABLE movies
ADD COLUMN series_id INT;
-- Ideally we would have `ADD COLUMN series_id INT REFERENCES series(series_id)`,
-- but DuckDB does not yet allow a foreign key constraint on a newly added column
