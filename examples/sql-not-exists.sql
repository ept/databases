-- name: Result of the NOT EXISTS query on s:exists
-- headers: auto
-- tt: movie_id
-- The query is code/sql-not-exists.sql, with ORDER BY added to pin the row order.
-- Must come out byte-identical to no-actors.tex and sql-not-in.tex: these are all
-- the same question, asked three ways, and all now return movie_id and title.
SELECT movie_id, title
FROM   movies AS m
WHERE NOT EXISTS (
    SELECT 1 FROM plays_role AS r
    WHERE r.movie_id = m.movie_id
)
ORDER BY title;
