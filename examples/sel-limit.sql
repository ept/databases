-- name: SELECT * FROM movies LIMIT 4
-- headers: auto
-- tt: movie_id
-- As in sel-all.sql, the ORDER BY is here only to pin the output; the query on the slide
-- (code/sel-2-limit.sql) has none, and returns these same four rows on this data.
SELECT * FROM movies ORDER BY movie_id LIMIT 4;
