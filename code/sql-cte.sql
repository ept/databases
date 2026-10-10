-- Define per_year as a name you can refer to later
WITH per_year AS (  
    SELECT year, COUNT(*) AS n_movies
    FROM movies GROUP BY year
)
SELECT year, n_movies FROM per_year  -- Now use it
WHERE n_movies > 140;
