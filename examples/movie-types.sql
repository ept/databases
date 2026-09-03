-- name: The distinct values of movies.type, most common first
-- format: list
-- tt: type
-- conjunction: or
SELECT type FROM movies GROUP BY type ORDER BY count(*) DESC;
