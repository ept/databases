-- name: Result of code/q-json-actor-director.sql, for the solution to q:json-queries
-- headers: auto
-- The query is code/q-json-actor-director.sql; keep the two identical.
SELECT   movie->>'title' AS title, movie->>'year' AS year
FROM     movies
WHERE    list_has_any(movie->>'$.directors[*].person_id',
                      movie->>'$.actors[*].person_id')
ORDER BY (movie->>'rating')::DOUBLE DESC, title
LIMIT    5;
