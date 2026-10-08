SELECT year, COUNT(*) AS n_movies
FROM   movies
GROUP BY year
HAVING n_movies > 140
ORDER BY year;
