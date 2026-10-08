-- name: SELECT type FROM movies, showing the duplicates
-- headers: auto
-- maxrows: 3
-- The query is code/sql-dup.sql; ORDER BY is added here only to make the truncated
-- excerpt deterministic. Showing repeated values is the whole point, so do not
-- deduplicate this one.
SELECT type FROM movies ORDER BY type;
