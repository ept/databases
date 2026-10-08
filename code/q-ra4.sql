SELECT title, string_agg(name, ', ' ORDER BY name) AS genres
FROM   movies
JOIN   has_genre USING (movie_id)
JOIN   genres USING (genre_id)
GROUP BY movie_id, title;
