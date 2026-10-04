-- name: the same with ORDER BY year DESC
-- headers: auto
-- tt: movie_id
-- ORDER BY year alone leaves ties in an unspecified order, so title breaks them and the
-- fragment does not change from one build to the next.
SELECT * FROM movies ORDER BY year DESC, title LIMIT 4;
