-- name: Two movies laid out row by row, for the logical/physical diagram
-- format: list
-- template: {movie_id}|{title}|{year}
-- separator: \\
-- Shown beside layout-column.sql, which is the same two movies laid out the other way;
-- keep the two queries in step. The separator is a LaTeX line break, so the result goes
-- in a node with align=left.
SELECT movie_id, title, year
FROM movies
WHERE movie_id IN ('tt0012349', 'tt0078748')
ORDER BY year;
