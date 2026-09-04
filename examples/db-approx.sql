-- name: Table sizes rounded down for use in prose ("roughly 2,900 movies")
-- format: macros
-- prefix: dbapprox
-- thousands: rounded
SELECT 'movies' AS name, cast(floor(count(*) / 100.0) AS int) * 100 AS rounded FROM movies
UNION ALL SELECT 'people', cast(floor(count(*) / 1000.0) AS int) * 1000 FROM people;
