ALTER TABLE movies DROP COLUMN studio_id;

CREATE TABLE made_by(
  movie_id  TEXT REFERENCES movies(movie_id),
  studio_id INT  REFERENCES studios(studio_id),
  PRIMARY KEY (movie_id, studio_id)
);
