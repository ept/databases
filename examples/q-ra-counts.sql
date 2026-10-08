-- name: Row counts quoted in the exercise solutions
-- format: macros
-- prefix: qcount
-- thousands: n
-- So the solutions can say how many rows each query returns without anyone counting by
-- hand. LaTeX command names cannot contain digits, hence "moviesinyear" rather than
-- "movies1995". The year and length must match code/q-ra1.sql and code/q-ra2.sql.
SELECT 'moviesinyear' AS name, count(*) AS n FROM movies WHERE year = 1995
UNION ALL SELECT 'longmovies', count(*) FROM movies WHERE minutes >= 180
UNION ALL SELECT 'moviegenrepairs', count(*)
    FROM movies JOIN has_genre USING (movie_id) JOIN genres USING (genre_id)
-- For q:intersect-join: movies that are in both the Crime and Drama genres. Must match
-- the genre_ids in code/sql-set-ops.sql and code/q-intersect-join.sql.
-- For q:position-tables: (movie, person) pairs holding more than one position, which is
-- why position has to be part of the primary key of has_position.
UNION ALL SELECT 'multiposition', count(*) FROM (
    SELECT movie_id, person_id FROM has_position
    GROUP BY movie_id, person_id HAVING count(*) > 1)
-- For q:position-tables: distinct free-text job values, an uncontrolled vocabulary.
UNION ALL SELECT 'distinctjobs', count(DISTINCT job) FROM has_position
UNION ALL SELECT 'crimedrama', count(*) FROM (
    SELECT movie_id FROM has_genre WHERE genre_id = 6
    INTERSECT
    SELECT movie_id FROM has_genre WHERE genre_id = 8);
