-- name: The has_genre excerpt once more, for the composite primary key slide
-- headers: auto
-- tt: movie_id
-- mark: movie_id=ckhm, genre_id=ckhg
-- The same rows as fk-has-genre.sql, with their own mark prefix because TeX node names
-- are global. s:composite-key circles the repeated values, so the excerpt must contain a
-- movie_id that appears twice and a genre_id that appears twice: here tt0120338 (rows 2
-- and 3) and 8 (rows 1 and 2). If the genre assignments in the data change, re-check it.
SELECT movie_id, genre_id
FROM has_genre
WHERE movie_id IN ('tt0078748', 'tt0120338', 'tt6751668')
  AND genre_id IN (8, 21, 22)
ORDER BY movie_id DESC, genre_id;
