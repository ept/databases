-- name: Result of the GROUP BY example on s:group-by
-- headers: auto
-- The query is code/sql-group-by.sql; keep the two identical, ORDER BY included.
-- The year cutoff is chosen so the whole result is five rows and fits on the slide.
SELECT year, count(*) AS n_movies
FROM   movies
WHERE  year >= 2021
GROUP BY year
ORDER BY year;
