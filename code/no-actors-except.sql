SELECT movie_id, title FROM movies
EXCEPT
SELECT movie_id, title FROM movies JOIN plays_role USING (movie_id);
