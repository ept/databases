SELECT title, rating
FROM   movies
JOIN   ratings ON movies.movie_id = ratings.movie_id;
