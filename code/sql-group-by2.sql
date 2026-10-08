SELECT year, type, COUNT(*) AS n_movies
FROM   movies
WHERE  year >= 2023
GROUP BY year, type
ORDER BY year, type;
