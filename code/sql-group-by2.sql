SELECT year, type, count(*) AS n_movies
FROM   movies
WHERE  year >= 2023
GROUP BY year, type
ORDER BY year, type;
