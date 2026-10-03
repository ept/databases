-- name: Result of the worked SELECT on s:select
-- headers: auto
-- The query is code/sql-select.sql; keep the two in step.
SELECT title, year
FROM   movies
WHERE  year >= 1995 AND type = 'movie'
ORDER BY year
LIMIT  3;
