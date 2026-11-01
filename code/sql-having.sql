SELECT year, COUNT(*) AS n_movies
FROM   movies
GROUP BY year
HAVING COUNT(*) > 140
ORDER BY year;
