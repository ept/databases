SELECT COUNT(*) FROM movies
WHERE  (movie->>'rating')::DOUBLE >= 8;
