-- name: Result of code/q-json-wachowski-people.sql, for the solution to q:json-queries
-- headers: auto
-- tt: movie_id
-- The query is code/q-json-wachowski-people.sql; keep the two identical.
SELECT DISTINCT c->>'movie_id' AS movie_id,
                c->>'title'    AS title,
                c->>'year'     AS year
FROM     people, unnest(person->'$.*[*]') AS t(c)
WHERE    (person->>'name') = 'Lana Wachowski'
ORDER BY year, title;
