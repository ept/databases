-- name: the same again with the year column renamed
-- headers: auto
-- The query shown on the slide is code/sel-6-rename.sql; the ORDER BY only pins the row
-- order, as in sel-where2.sql.
SELECT title, year AS release_year FROM movies
WHERE  type = 'video' AND year >= 2012
ORDER BY year, title;
