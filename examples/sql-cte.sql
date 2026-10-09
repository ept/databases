-- name: Result of the CTE on s:cte
-- headers: auto
-- The query is code/sql-cte.sql, with ORDER BY added to pin the row order.
-- This must come out byte-identical to sql-having.tex: the whole point of the
-- subsection is that the HAVING, subquery and CTE forms are the same query.
WITH per_year AS (
    SELECT year, count(*) AS n_movies
    FROM movies GROUP BY year
)
SELECT year, n_movies FROM per_year
WHERE n_movies > 140
ORDER BY year;
