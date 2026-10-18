SELECT 'movies' AS tbl, movie_id AS id
FROM   movies
WHERE  list_contains(movie->>'$.*[*].person_id', 'nm0000122')
UNION ALL
SELECT 'people', person_id
FROM   people
WHERE  person_id = 'nm0000122';
