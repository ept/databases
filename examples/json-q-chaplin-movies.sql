-- name: Result of code/q-json-chaplin-movies.sql, for the solution to q:json-queries
-- headers: auto
-- The query is code/q-json-chaplin-movies.sql; keep the two identical.
SELECT   movie->>'title' AS title, movie->>'year' AS year
FROM     movies
WHERE    list_contains(movie->>'$.actors[*].name', 'Charles Chaplin')
ORDER BY year;
