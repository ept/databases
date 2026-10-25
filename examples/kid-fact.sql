-- name: The Kid's row of movies, as macros for the Datalog fact and its tuple on s:relation-math
-- format: macros
-- prefix: kidfact
SELECT 'id' AS name, movie_id AS value FROM movies WHERE title = 'The Kid' AND year = 1921
UNION ALL SELECT 'title', title FROM movies WHERE title = 'The Kid' AND year = 1921
UNION ALL SELECT 'year', CAST(year AS TEXT) FROM movies WHERE title = 'The Kid' AND year = 1921
UNION ALL SELECT 'type', type FROM movies WHERE title = 'The Kid' AND year = 1921
UNION ALL SELECT 'minutes', CAST(minutes AS TEXT) FROM movies WHERE title = 'The Kid' AND year = 1921;
