CREATE TABLE movies(
  movie_id  TEXT PRIMARY KEY,  -- e.g. 'tt0012349'
  movie     JSON NOT NULL      -- the whole document
);

CREATE TABLE people(
  person_id TEXT PRIMARY KEY,  -- e.g. 'nm0000122'
  person    JSON NOT NULL
);
