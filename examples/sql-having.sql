-- name: Result of the HAVING example on s:having
-- headers: auto
-- The query is code/sql-having.sql; keep the two identical, ORDER BY included.
-- The threshold is chosen so that the result is three rows. There is no year filter
-- here, unlike sql-group-by.sql, but the two results do not overlap in any case, so
-- the slides do not appear to contradict each other. If a refresh leaves no year above
-- the threshold, render.py fails on the empty result rather than printing nothing.
SELECT year, count(*) AS n_movies
FROM   movies
GROUP BY year
HAVING n_movies > 140
ORDER BY year;
