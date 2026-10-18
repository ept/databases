SELECT   movie->>'title' AS title, movie->>'year' AS year
FROM     movies
WHERE    list_has_any(movie->>'$.directors[*].person_id',
                      movie->>'$.actors[*].person_id')
ORDER BY (movie->>'rating')::DOUBLE DESC, title
LIMIT    5;
