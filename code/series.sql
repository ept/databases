CREATE TABLE series(
  series_id INT PRIMARY KEY,
  name      TEXT
);

-- movies gains one column: a foreign key that is not part of its primary key
CREATE TABLE movies(
  movie_id  TEXT PRIMARY KEY,
  title     TEXT,
  year      INT,
  type      TEXT,
  minutes   INT,
  series_id INT REFERENCES series(series_id)
);
