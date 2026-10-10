-- name: Result of the NOT EXISTS query on s:exists
-- headers: auto
-- The query is code/sql-not-exists.sql, with ORDER BY added to pin the row order.
-- This must come out byte-identical to no-actors.tex, the left-join anti-join in the
-- solution to q:no-actors: the slide's claim is that the two are the same question.
SELECT title FROM movies AS m
WHERE NOT EXISTS (
    SELECT 1 FROM plays_role AS r
    WHERE r.movie_id = m.movie_id
)
ORDER BY title;
