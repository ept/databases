SELECT   movie->>'title' AS title, movie->>'year' AS year
FROM     movies
WHERE    list_contains(movie->>'$.actors[*].name', 'Charles Chaplin')
ORDER BY year;
