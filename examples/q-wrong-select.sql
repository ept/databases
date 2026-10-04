-- name: What the mistaken query in q:select-projection actually returns
-- headers: year = 1995
-- maxrows: 4
-- DuckDB names the column ("year" = 1995); the headers directive tidies that to the
-- expression as written. ORDER BY is added only to make the excerpt deterministic.
SELECT year = 1995 FROM movies ORDER BY title;
