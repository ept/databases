-- name: Result of code/q-json-chaplin-movies.sql, for the solution to q:json-queries
-- headers: auto
-- The query is code/q-json-chaplin-movies.sql; keep the two identical.
SELECT   data->>'title' AS title, data->>'year' AS year
FROM     movies
WHERE    list_contains(data->>'$.actors[*].name', 'Charles Chaplin')
ORDER BY year;
