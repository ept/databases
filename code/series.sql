CREATE TABLE series(
  series_id INT PRIMARY KEY,
  name      TEXT
);

ALTER TABLE movies
  ADD COLUMN series_id INT REFERENCES series(series_id);
