WITH per_year AS (
    SELECT year, count(*) AS n_movies
    FROM movies GROUP BY year
)
SELECT year, n_movies FROM per_year
WHERE n_movies > 140;
