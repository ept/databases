-- name: Result of code/q-json-directors.sql, for the solution to q:json-queries
-- headers: auto
-- The query is code/q-json-directors.sql; keep the two identical.
SELECT   data->>'name' AS name,
         json_array_length(data, '$.directed') AS n_movies
FROM     people
ORDER BY n_movies DESC, name
LIMIT    5;
