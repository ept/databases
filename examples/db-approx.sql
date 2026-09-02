-- name: Table sizes rounded down for use in prose ("roughly 2,900 movies")
-- format: macros
-- prefix: dbapprox
-- thousands: rounded
SELECT 'movies' AS name, count(*) / 100 * 100 AS rounded FROM movies
UNION ALL SELECT 'people', count(*) / 1000 * 1000 FROM people;
