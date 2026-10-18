SELECT person_id AS id FROM people
WHERE  person_id = 'nm0905154'
UNION ALL
SELECT movie_id FROM movies
WHERE  list_contains(movie->>'$.*[*].person_id', 'nm0905154')
ORDER BY id;
