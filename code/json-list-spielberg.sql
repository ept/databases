SELECT movie->>'title' AS title, movie->>'year' AS year
FROM   movies
WHERE  list_contains(movie->>'$.directors[*].name',
                     'Steven Spielberg')
ORDER BY year
LIMIT  3;
