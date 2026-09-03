-- name: has_genre rows referring only to the movies and genres shown on the same slide
-- headers: auto
-- tt: movie_id
-- mark: movie_id=fkhm, genre_id=fkhg
-- Restricted to the rows of fk-movies.sql and fk-genres.sql so that every value on the
-- slide points at something else on the slide.
-- The row order is chosen so that the values the slide joins up sit on the facing
-- edges of adjacent tables, which keeps the connecting lines short and stops them
-- crossing any cell text. If you change it, re-check s:foreign-key.
SELECT movie_id, genre_id
FROM has_genre
WHERE movie_id IN ('tt0078748', 'tt0120338', 'tt6751668')
  AND genre_id IN (8, 21, 22)
ORDER BY movie_id DESC, genre_id;
