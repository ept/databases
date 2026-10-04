-- name: Row counts for the three parts of q:ra-translate
-- format: macros
-- prefix: qcount
-- thousands: n
-- So the solutions can say how many rows each query returns without anyone counting by
-- hand. LaTeX command names cannot contain digits, hence "moviesinyear" rather than
-- "movies1995". The year and length must match code/q-ra1.sql and code/q-ra2.sql.
SELECT 'moviesinyear' AS name, count(*) AS n FROM movies WHERE year = 1995
UNION ALL SELECT 'longmovies', count(*) FROM movies WHERE minutes >= 180
UNION ALL SELECT 'moviegenrepairs', count(*)
    FROM movies JOIN has_genre USING (movie_id) JOIN genres USING (genre_id);
