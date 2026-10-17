SELECT COUNT(*) FROM movies
WHERE  (data->'rating') >= 8;
