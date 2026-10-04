-- name: An excerpt of movies x genres: one movie against the first few genres
-- headers: auto
-- tt: movie_id
-- maxrows: 4
-- The full product has no inherent order and is far too big to show, so this is the
-- slice for a single movie: the point is that its five columns repeat unchanged while
-- the genre columns vary. The Kid is the running example from s:moviedb-kid1.
SELECT * FROM movies, genres
WHERE movie_id = 'tt0012349' AND genre_id <= 5
ORDER BY genre_id;
