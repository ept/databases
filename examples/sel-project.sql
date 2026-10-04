-- name: the same rows as sel-where2, projected onto two columns
-- headers: auto
-- The query shown on the slide is code/sel-5-project.sql; the ORDER BY only pins the row
-- order, as in sel-where2.sql.
SELECT title, year FROM movies
WHERE  type = 'video' AND year >= 2012
ORDER BY year, title;
