-- name: the same with the year column renamed
-- headers: auto
-- The query shown on the slide is code/sel-6-rename.sql; keep the two in step.
SELECT title, year AS release_year FROM movies
WHERE  year >= 2013 AND type = 'movie'
ORDER BY movie_id
LIMIT  4;
