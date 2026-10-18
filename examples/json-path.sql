-- name: Result of the JSONPath example on s:json-path
-- headers: auto
-- The query is code/json-path.sql; keep the two in step. See json-arrows.sql for why it
-- selects by movie_id.
SELECT movie->>'$.actors[0].name' AS first_actor,
       movie->>'$.genres[1]'      AS second_genre,
       movie->>'$.genres[*]'      AS all_genres
FROM   movies
WHERE  movie_id = 'tt0012349';
