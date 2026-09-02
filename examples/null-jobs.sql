-- name: Percentage of has_position rows whose job is null (the % sign is added in databases.tex)
-- format: scalar
SELECT cast(round(100.0 * sum(CASE WHEN job IS NULL THEN 1 ELSE 0 END) / count(*)) AS int) AS pct
FROM has_position;
