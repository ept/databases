SELECT data->>'$.actors[0].name' AS first_actor,
       data->>'$.genres[1]'      AS second_genre,
       data->>'$.genres[*]'      AS all_genres
FROM   movies
WHERE  movie_id = 'tt0012349';
