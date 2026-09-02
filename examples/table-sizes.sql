-- name: Number of rows in each table
-- format: macros
-- prefix: dbrows
-- thousands: rows
SELECT 'movies'      AS name, count(*) AS rows FROM movies
UNION ALL SELECT 'people',       count(*) FROM people
UNION ALL SELECT 'genres',       count(*) FROM genres
UNION ALL SELECT 'ratings',      count(*) FROM ratings
UNION ALL SELECT 'hasgenre',     count(*) FROM has_genre
UNION ALL SELECT 'hasposition',  count(*) FROM has_position
UNION ALL SELECT 'playsrole',    count(*) FROM plays_role;
