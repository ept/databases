CREATE TABLE movies(
  movie_id TEXT PRIMARY KEY,
  title    TEXT,
  year     INT,
  type     TEXT,
  minutes  INT
);

CREATE TABLE people(
  person_id TEXT PRIMARY KEY,
  name      TEXT,
  birthyear INT,
  deathyear INT
);

CREATE TABLE genres(
  genre_id INT PRIMARY KEY,
  name     TEXT
);
