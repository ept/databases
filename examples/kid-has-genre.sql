-- name: The Kid's rows in the has_genre table
-- tt: movie_id
SELECT hg.movie_id, hg.genre_id
FROM has_genre hg JOIN movies m USING (movie_id)
WHERE m.title = 'The Kid' AND m.year = 1921
ORDER BY hg.genre_id;
