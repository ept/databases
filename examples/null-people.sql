-- name: Percentage of people rows with no birth year and with no death year
-- format: macros
-- prefix: dbnull
SELECT 'birthyear' AS name,
       cast(round(100.0 * sum(CASE WHEN birthyear IS NULL THEN 1 ELSE 0 END) / count(*)) AS int) AS pct
FROM people
UNION ALL
SELECT 'deathyear',
       cast(round(100.0 * sum(CASE WHEN deathyear IS NULL THEN 1 ELSE 0 END) / count(*)) AS int)
FROM people;
