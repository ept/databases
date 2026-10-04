SELECT title, rating
FROM   movies
JOIN   ratings USING (movie_id);
