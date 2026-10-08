SELECT year, COUNT(*) AS n_movies
FROM   movies
WHERE  year >= 2021
GROUP BY year
ORDER BY year;
