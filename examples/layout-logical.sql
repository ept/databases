-- name: The same two movies as a logical table, for the logical/physical diagram
-- format: table
-- headers: auto
-- rules: plain
-- tt: movie_id
SELECT movie_id, title, year
FROM movies
WHERE movie_id IN ('tt0012349', 'tt0078748')
ORDER BY year;
