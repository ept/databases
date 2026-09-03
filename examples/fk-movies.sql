-- name: The movies excerpt again, for the foreign key slide
-- headers: auto
-- tt: movie_id
-- mark: movie_id=fkm
-- Must show the same rows as pk-movies.sql.
SELECT movie_id, title, year
FROM movies
WHERE movie_id IN ('tt0078748', 'tt0120338', 'tt6751668')
ORDER BY year;
