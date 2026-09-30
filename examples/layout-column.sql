-- name: The same two movies laid out column by column, for the logical/physical diagram
-- format: list
-- template: {line}
-- separator: \\
-- One row per column of the table: the transpose of layout-row.sql.
WITH m AS (
    SELECT movie_id, title, year FROM movies
    WHERE movie_id IN ('tt0012349', 'tt0078748')
)
SELECT string_agg(movie_id, ',' ORDER BY year) AS line FROM m
UNION ALL SELECT string_agg(title, ',' ORDER BY year) FROM m
UNION ALL SELECT string_agg(year::TEXT, ',' ORDER BY year) FROM m;
