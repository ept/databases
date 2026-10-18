SELECT COUNT(*) FROM movies
WHERE  (movie->'rating') >= 8;
