SELECT movie_id
FROM   (has_genre AS h1 JOIN genres AS g1 USING (genre_id))
JOIN   (has_genre AS h2 JOIN genres AS g2 USING (genre_id))
       USING (movie_id)
WHERE  g1.name = 'Crime' AND g2.name = 'Drama';
