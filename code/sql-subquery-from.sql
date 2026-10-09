SELECT year, n_movies
FROM  (SELECT year, count(*) AS n_movies
       FROM movies GROUP BY year) AS per_year
WHERE n_movies > 140;
