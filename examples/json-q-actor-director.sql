-- name: Result of code/q-json-actor-director.sql, for the solution to q:json-queries
-- headers: auto
-- The query is code/q-json-actor-director.sql; keep the two identical.
SELECT   data->>'title' AS title, data->>'year' AS year
FROM     movies
WHERE    list_has_any(data->>'$.directors[*].person_id',
                      data->>'$.actors[*].person_id')
ORDER BY (data->>'rating')::DOUBLE DESC, title
LIMIT    5;
