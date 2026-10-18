SELECT   movie_id, movie->>'title' AS title, movie->>'year' AS year
FROM     movies
WHERE    list_contains(movie->>'$.*[*].name', 'Lana Wachowski')
ORDER BY year, title;
