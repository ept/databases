-- name: SELECT * FROM movies, truncated to fit a slide
-- headers: auto
-- tt: movie_id
-- maxrows: 4
-- The query on the slide (code/sel-1-all.sql) has no ORDER BY, which is the point of the
-- slide; this one adds one so that the fragment does not change between database builds.
-- Checked: on this data the unordered query returns these same four rows first, so the
-- result shown is the one a reader actually gets.
SELECT * FROM movies ORDER BY movie_id;
