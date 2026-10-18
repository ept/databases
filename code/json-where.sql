SELECT movie->>'title' AS title, movie->>'year' AS year
FROM   movies
WHERE  (movie->>'title') LIKE 'Star Wars%'
  AND  (movie->>'year')::INTEGER >= 2000
ORDER BY year;
