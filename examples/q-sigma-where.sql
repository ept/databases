-- name: What the correct translation of sigma_{year=1995}(movies) returns
-- headers: auto
-- tt: movie_id
-- maxrows: 3
-- The solution shows code/q-sigma-where.sql, which has no ORDER BY; it is added here
-- only to make the truncated excerpt deterministic. Pairs with q-wrong-select.sql,
-- which must stay the same query minus the WHERE clause.
SELECT * FROM movies WHERE year = 1995 ORDER BY title;
