-- name: Result of the aggregation example on s:json-group
-- headers: auto
-- thousands: n_movies
-- The query is code/json-group.sql; keep the two identical, ORDER BY included.
SELECT   genre, COUNT(*) AS n_movies
FROM     movies, unnest(movie->>'$.genres[*]') AS t(genre)
GROUP BY genre
ORDER BY n_movies DESC, genre
LIMIT    5;
