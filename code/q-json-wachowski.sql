WITH lana AS (
    SELECT person_id FROM people
    WHERE  (person->>'name') = 'Lana Wachowski'
)
SELECT person_id AS id FROM lana
UNION ALL
SELECT movie_id FROM movies, lana
WHERE  list_contains(movie->>'$.*[*].person_id', lana.person_id)
ORDER BY id;
