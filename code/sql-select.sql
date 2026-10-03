SELECT title, year
FROM   movies
WHERE  year >= 1995 AND type = 'movie'
ORDER BY year
LIMIT  3;
