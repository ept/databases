SELECT movie->>'$.actors[0].name' AS first_actor,
       movie->>'$.genres[1]'      AS second_genre,
       movie->>'$.genres[*]'      AS all_genres
FROM   movies
WHERE  movie_id = 'tt0012349';
