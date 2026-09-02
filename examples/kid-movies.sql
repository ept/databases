-- name: The Kid's row in the movies table
-- tt: movie_id
SELECT movie_id, title, year, type, minutes
FROM movies WHERE title = 'The Kid' AND year = 1921;
