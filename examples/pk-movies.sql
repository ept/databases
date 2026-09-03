-- name: A three-row excerpt of movies, for the primary key slide
-- headers: auto
-- tt: movie_id
-- mark: movie_id=pkm
-- The same three movies appear in fk-movies.sql; keep the two in step.
SELECT movie_id, title, year
FROM movies
WHERE movie_id IN ('tt0078748', 'tt0120338', 'tt6751668')
ORDER BY year;
