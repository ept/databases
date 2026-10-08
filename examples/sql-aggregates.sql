-- name: Result of the aggregate functions example on s:aggregates
-- headers: auto
-- round: mean=2
-- The query is code/sql-aggregates.sql; keep the two identical.
-- One row, because with no GROUP BY the whole table is a single group. The mean is
-- rounded here only for display; the query itself returns full precision.
SELECT count(*) AS n_movies, min(rating) AS worst,
       max(rating) AS best, avg(rating) AS mean
FROM   ratings;
