SELECT count(*) AS n_movies, min(rating) AS worst,
       max(rating) AS best, avg(rating) AS mean
FROM   ratings;
