-- name: Result of the JSONPath example on s:json-path
-- headers: auto
-- The query is code/json-path.sql; keep the two in step. See json-arrows.sql for why it
-- selects by movie_id.
SELECT data->>'$.actors[0].name' AS first_actor,
       data->>'$.genres[1]'      AS second_genre,
       data->>'$.genres[*]'      AS all_genres
FROM   movies
WHERE  movie_id = 'tt0012349';
