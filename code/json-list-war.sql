SELECT COUNT(*) FROM movies
WHERE  list_contains(data->>'$.genres[*]', 'War');
