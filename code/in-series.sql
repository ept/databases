-- movies reverts to its original definition, without series_id
CREATE TABLE in_series(
  movie_id  TEXT REFERENCES movies(movie_id),
  series_id INT  REFERENCES series(series_id),
  PRIMARY KEY (movie_id, series_id)
);
