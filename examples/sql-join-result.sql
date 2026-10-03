-- name: Result of the join on s:joins
-- headers: auto
-- round: rating=1
-- The query is code/sql-join.sql; keep the two in step.
SELECT title, rating
FROM   movies JOIN ratings ON movies.movie_id = ratings.movie_id
ORDER BY rating DESC
LIMIT  3;
