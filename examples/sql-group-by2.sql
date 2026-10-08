-- name: Result of the two-column GROUP BY on s:group-by-multi
-- headers: auto
-- The query is code/sql-group-by2.sql; keep the two identical, ORDER BY included.
-- The cutoff is chosen so that the result is four rows and shows both things at once:
-- 2023 splits into two types, while 2024 and 2025 produce a single row each, since a
-- combination with no movies yields no row rather than a zero.
-- These counts must add up to the 2023 figure on s:group-by, which uses the same table
-- with no type split; if a refresh breaks that, re-check both slides together.
SELECT year, type, count(*) AS n_movies
FROM   movies
WHERE  year >= 2023
GROUP BY year, type
ORDER BY year, type;
