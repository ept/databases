-- name: Result of code/q-json-wachowski-movies.sql, for the solution to q:json-queries
-- headers: auto
-- tt: movie_id
-- The query is code/q-json-wachowski-movies.sql; keep the two identical.
SELECT   movie_id, movie->>'title' AS title, movie->>'year' AS year
FROM     movies
WHERE    list_contains(movie->>'$.*[*].name', 'Lana Wachowski')
ORDER BY year, title;
