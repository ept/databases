SELECT COUNT(*) FROM movies
WHERE  (data->>'rating')::DOUBLE >= 8;
