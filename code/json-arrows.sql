SELECT data->'title'  AS title_json,
       data->>'title' AS title_text,
       data->'genres' AS genres
FROM   movies
WHERE  movie_id = 'tt0012349';
