-- name: Result of code/q-json-wachowski.sql, for the solution to q:json-queries
-- headers: auto
-- tt: id
-- The query is code/q-json-wachowski.sql; keep the two identical.
WITH lana AS (
    SELECT person_id FROM people
    WHERE  (person->>'name') = 'Lana Wachowski'
)
SELECT person_id AS id FROM lana
UNION ALL
SELECT movie_id FROM movies, lana
WHERE  list_contains(movie->>'$.*[*].person_id', lana.person_id)
ORDER BY id;
