-- name: Result of code/q-json-genre-rating.sql, for the solution to q:json-queries
-- headers: auto
-- The query is code/q-json-genre-rating.sql; keep the two identical.
SELECT   genre,
         round(avg((data->>'rating')::DOUBLE), 2) AS avg_rating
FROM     movies, unnest(data->>'$.genres[*]') AS t(genre)
GROUP BY genre
ORDER BY avg_rating DESC, genre
LIMIT    5;
