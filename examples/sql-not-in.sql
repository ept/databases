-- name: Result of the NOT IN form of the no-actors query
-- headers: auto
-- The query is code/sql-not-in.sql, with ORDER BY added to pin the row order.
-- Must come out byte-identical to no-actors.tex and sql-not-exists.tex: the point of
-- the passage is that all three spellings answer the same question, and that this one
-- is safe only because plays_role.movie_id is part of a primary key and never null.
SELECT title FROM movies
WHERE movie_id NOT IN (SELECT movie_id FROM plays_role)
ORDER BY title;
