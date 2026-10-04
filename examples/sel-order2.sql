-- name: the same ordered by year descending, ties broken by title
-- headers: auto
-- tt: movie_id
-- The query shown on the slide is code/sel-3b-order2.sql; keep the two in step.
SELECT * FROM movies ORDER BY year DESC, title LIMIT 3;
