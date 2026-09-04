CREATE TABLE studios(
  studio_id INT PRIMARY KEY,
  name      TEXT
);

ALTER TABLE movies
  ADD COLUMN studio_id INT REFERENCES studios(studio_id);
