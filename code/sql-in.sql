-- same as: ... WHERE year = 1927 OR year = 1931
SELECT title, year FROM movies WHERE year IN (1927, 1931);
