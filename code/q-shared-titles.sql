SELECT title FROM movies
GROUP BY title
HAVING count(*) > 1;
