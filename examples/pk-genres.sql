-- name: A three-row excerpt of genres, for the primary key slide
-- headers: auto
-- mark: genre_id=pkg
-- The same three genres appear in fk-genres.sql; keep the two in step.
-- The row order is chosen so that the values the slide joins up sit on the facing
-- edges of adjacent tables, which keeps the connecting lines short and stops them
-- crossing any cell text. If you change it, re-check s:foreign-key.
SELECT genre_id, name
FROM genres
WHERE genre_id IN (8, 21, 22)
ORDER BY genre_id DESC;
