SELECT title, rating
FROM   movies JOIN ratings USING (movie_id)
WHERE  year = 1976
  AND  rating > (SELECT AVG(rating) FROM ratings);
