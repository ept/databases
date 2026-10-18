-- name: Result of code/q-json-wachowski.sql, for the solution to q:json-queries
-- headers: auto
-- tt: id
-- The query is code/q-json-wachowski.sql; keep the two identical.
SELECT person_id AS id FROM people
WHERE  person_id = 'nm0905154'
UNION ALL
SELECT movie_id FROM movies
WHERE  list_contains(movie->>'$.*[*].person_id', 'nm0905154')
ORDER BY id;
