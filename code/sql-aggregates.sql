SELECT COUNT(*) AS n_movies, MIN(rating) AS worst,
       MAX(rating) AS best, AVG(rating) AS mean
FROM   ratings;
