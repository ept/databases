-- name: Result of the LIKE example on s:in-like
-- headers: auto
-- tt: movie_id
-- The query is code/sql-like.sql; ORDER BY is added here only to pin the row order.
-- The Matrix films are a complete four-row result, and the pattern shows % matching
-- both the empty string (the first film) and a longer suffix.
SELECT * FROM movies
WHERE  title LIKE 'The Matrix%'
ORDER BY year, title;
