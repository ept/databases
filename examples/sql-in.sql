-- name: Result of the IN example on s:in-like
-- headers: auto
-- The query is code/sql-in.sql; ORDER BY is added here only to pin the row order.
-- These two years are chosen because between them they have just three movies, so the
-- whole result fits on the slide without a LIMIT.
SELECT title, year FROM movies
WHERE  year IN (1927, 1931)
ORDER BY year, title;
