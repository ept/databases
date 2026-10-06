SELECT g1.movie_id
FROM   has_genre AS g1
JOIN   has_genre AS g2 USING (movie_id)
WHERE  g1.genre_id = 6 AND g2.genre_id = 8;
