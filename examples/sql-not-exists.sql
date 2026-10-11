-- name: Result of the NOT EXISTS query on s:exists
-- headers: auto
-- The query is code/sql-not-exists.sql, with ORDER BY added to pin the row order.
-- Must come out byte-identical to sql-not-in.tex, the other slide asking this question.
-- It returns the same two movies as the anti-join in q:no-actors, but that solution
-- selects movie_id as well, so the rendered tables there differ by a column.
SELECT title FROM movies AS m
WHERE NOT EXISTS (
    SELECT 1 FROM plays_role AS r
    WHERE r.movie_id = m.movie_id
)
ORDER BY title;
