-- Which years have more than 140 movie releases?
SELECT year, n_movies
FROM  (SELECT year, COUNT(*) AS n_movies
       FROM movies GROUP BY year) AS per_year
WHERE n_movies > 140;
