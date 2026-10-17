-- name: Result of code/q-json-chaplin-people.sql, for the solution to q:json-queries
-- headers: auto
-- The query is code/q-json-chaplin-people.sql; keep the two identical.
SELECT   c->>'title' AS title, c->>'year' AS year
FROM     people, unnest(data->'$.acted_in[*]') AS t(c)
WHERE    (data->>'name') = 'Charles Chaplin'
ORDER BY year;
