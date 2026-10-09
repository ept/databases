-- name: Result of the scalar subquery on s:subquery-where
-- headers: auto
-- round: rating=1
-- The query is code/sql-subquery-where.sql; keep the two in step, ORDER BY aside.
-- 1976 is chosen because it has five movies of which exactly one, King Kong, is below
-- the overall mean rating, so the subquery is visibly doing work rather than letting
-- everything through. If a refresh changes that, pick another year with a mix.
SELECT title, rating
FROM   movies JOIN ratings USING (movie_id)
WHERE  year = 1976
  AND  rating > (SELECT avg(rating) FROM ratings)
ORDER BY title;
