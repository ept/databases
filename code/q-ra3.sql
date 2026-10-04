SELECT title, name FROM movies
JOIN has_genre USING (movie_id)
JOIN genres USING (genre_id);
