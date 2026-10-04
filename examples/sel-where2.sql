-- name: the video rows narrowed to 2012 onwards
-- headers: auto
-- tt: movie_id
-- The query shown on the slide is code/sel-4b-where2.sql; the ORDER BY is here only to
-- pin the row order, as in sel-where.sql.
SELECT * FROM movies
WHERE  type = 'video' AND year >= 2012
ORDER BY year, title;
