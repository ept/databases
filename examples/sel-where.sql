-- name: every row of movies whose type is 'video'
-- headers: auto
-- tt: movie_id
-- There are only six of these in the whole table, so the result is complete rather than
-- truncated; the ORDER BY is for reproducibility, the slide's query has none.
SELECT * FROM movies WHERE type = 'video' ORDER BY year;
