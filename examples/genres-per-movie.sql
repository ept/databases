-- name: Mean number of genres per movie
-- format: scalar
-- round: avg=1
SELECT cast(count(*) AS real) / (SELECT count(*) FROM movies) AS avg FROM has_genre;
