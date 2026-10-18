SELECT COUNT(*) FROM movies
WHERE  list_contains(movie->>'$.genres[*]', 'War');
