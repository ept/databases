-- name: the same projected onto two columns
-- headers: auto
-- The query shown on the slide is code/sel-5-project.sql; keep the two in step.
SELECT title, year FROM movies
WHERE  year >= 2013 AND type = 'movie'
ORDER BY movie_id
LIMIT  4;
