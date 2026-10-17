-- name: Result of the arrow-operator example on s:json-arrows
-- headers: auto
-- tt: title_json, genres
-- The query is code/json-arrows.sql; keep the two in step. Selecting by movie_id is
-- deliberate here, unlike elsewhere: the key column is the only thing outside the
-- document, and the slide has not yet shown how to look inside it in a WHERE clause.
SELECT data->'title'  AS title_json,
       data->>'title' AS title_text,
       data->'genres' AS genres
FROM   movies
WHERE  movie_id = 'tt0012349';
