SELECT title, year AS release_year FROM movies
WHERE  year >= 2013 AND type = 'movie'
LIMIT  4;
