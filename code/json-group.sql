SELECT   genre, COUNT(*) AS n_movies
FROM     movies, unnest(movie->>'$.genres[*]') AS t(genre)
GROUP BY genre
ORDER BY n_movies DESC, genre
LIMIT    5;
