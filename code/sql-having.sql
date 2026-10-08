SELECT year, count(*) AS n_movies
FROM   movies
GROUP BY year
HAVING count(*) > 140
ORDER BY year;
