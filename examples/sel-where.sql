-- name: the same with a WHERE clause
-- headers: auto
-- tt: movie_id
-- The query shown on the slide is code/sel-4-where.sql; keep the two in step.
SELECT * FROM movies
WHERE  year >= 2013 AND type = 'movie'
ORDER BY movie_id
LIMIT  4;
