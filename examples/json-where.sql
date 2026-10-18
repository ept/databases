-- name: Result of the selection example on s:json-where
-- headers: auto
-- maxrows: 5
-- The query is code/json-where.sql; keep the two in step. year is text here (->> returns
-- VARCHAR), but four-digit years sort the same as text and as numbers.
SELECT movie->>'title' AS title, movie->>'year' AS year
FROM   movies
WHERE  (movie->>'title') LIKE 'Star Wars%'
  AND  (movie->>'year')::INTEGER >= 2000
ORDER BY year;
