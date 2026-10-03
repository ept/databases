CREATE TABLE genres(
  genre_id INT  PRIMARY KEY,   -- unique, identifies a row
  name     TEXT NOT NULL UNIQUE
);

CREATE TABLE has_genre(
  movie_id TEXT REFERENCES movies(movie_id),
  genre_id INT  REFERENCES genres(genre_id),
  PRIMARY KEY (movie_id, genre_id)
);
