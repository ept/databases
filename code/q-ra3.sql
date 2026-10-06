SELECT title, name FROM movies
JOIN has_genre ON movies.movie_id = has_genre.movie_id
JOIN genres ON has_genre.genre_id = genres.genre_id;
