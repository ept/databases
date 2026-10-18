SELECT movie->'title'  AS title_json,
       movie->>'title' AS title_text,
       movie->'genres' AS genres
FROM   movies
WHERE  movie_id = 'tt0012349';
