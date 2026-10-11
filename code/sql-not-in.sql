SELECT movie_id, title FROM movies
WHERE movie_id NOT IN (SELECT movie_id FROM plays_role);
