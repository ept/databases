-- name: Result of the nested-array example on s:json-lists
-- headers: auto
-- The query is code/json-list-spielberg.sql; keep the two in step.
SELECT movie->>'title' AS title, movie->>'year' AS year
FROM   movies
WHERE  list_contains(movie->>'$.directors[*].name',
                     'Steven Spielberg')
ORDER BY year
LIMIT  3;
