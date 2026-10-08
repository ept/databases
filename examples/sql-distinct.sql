-- name: SELECT DISTINCT type FROM movies
-- headers: auto
-- The query is code/sql-distinct.sql; ORDER BY is added here only to pin the row order.
-- A complete result: the table has only a handful of distinct types.
SELECT DISTINCT type FROM movies ORDER BY type;
