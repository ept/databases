CREATE TABLE ratings(
  movie_id TEXT PRIMARY KEY REFERENCES movies(movie_id),
  rating   NUMERIC,
  votes    INT
);
CREATE TABLE has_genre(
  movie_id TEXT REFERENCES movies(movie_id),
  genre_id INT  REFERENCES genres(genre_id),
  PRIMARY KEY (movie_id, genre_id)
);
CREATE TABLE has_position(
  person_id TEXT REFERENCES people(person_id),
  movie_id  TEXT REFERENCES movies(movie_id),
  position  TEXT,
  job       TEXT,
  PRIMARY KEY (movie_id, person_id, position)
);
CREATE TABLE plays_role(
  person_id TEXT REFERENCES people(person_id),
  movie_id  TEXT REFERENCES movies(movie_id),
  role      TEXT,
  PRIMARY KEY (movie_id, person_id, role)
);
