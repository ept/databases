-- name: Row counts quoted in the notes, slides and solutions
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
-- For the NOT IN discussion after s:exists: the same query shape over a nullable
-- column. nullinwrong must be 0 and nullinright must be greater than it; if a refresh
-- ever makes them equal, the passage's claim has stopped being true.
UNION ALL SELECT 'nullinwrong', count(*) FROM movies
    WHERE year NOT IN (SELECT deathyear FROM people)
UNION ALL SELECT 'nullinright', count(*) FROM movies
    WHERE year NOT IN (SELECT deathyear FROM people WHERE deathyear IS NOT NULL)
-- For s:semijoin: people with at least one composer credit, and the number of credits.
-- The first is what the semijoin returns, the second what a JOIN would; the slide
-- contrasts them, so they must stay different.
UNION ALL SELECT 'composers', count(DISTINCT person_id) FROM has_position
    WHERE position = 'composer'
UNION ALL SELECT 'composercredits', count(*) FROM has_position
    WHERE position = 'composer'
-- For q:position-tables: (movie, person) pairs holding more than one position, which is
-- why position has to be part of the primary key of has_position.
UNION ALL SELECT 'multiposition', count(*) FROM (
    SELECT movie_id, person_id FROM has_position
    GROUP BY movie_id, person_id HAVING count(*) > 1)
-- For q:position-tables: distinct free-text job values, an uncontrolled vocabulary.
UNION ALL SELECT 'distinctjobs', count(DISTINCT job) FROM has_position
-- For s:union-all: the two sides of the union and the result each way. crime + drama
-- must equal unionallrows, and unionrows must be that less crimedrama; the slide states
-- that arithmetic, so if a refresh breaks it the slide is wrong.
UNION ALL SELECT 'crime', count(*) FROM has_genre WHERE genre_id = 6
UNION ALL SELECT 'drama', count(*) FROM has_genre WHERE genre_id = 8
UNION ALL SELECT 'unionrows', count(*) FROM (
    SELECT movie_id FROM has_genre WHERE genre_id = 6
    UNION
    SELECT movie_id FROM has_genre WHERE genre_id = 8)
UNION ALL SELECT 'unionallrows', count(*) FROM (
    SELECT movie_id FROM has_genre WHERE genre_id = 6
    UNION ALL
    SELECT movie_id FROM has_genre WHERE genre_id = 8)
-- For q:intersect-join and s:union-all: movies in both the Crime and Drama genres.
-- Must match the genre_ids in code/sql-set-ops.sql and code/q-intersect-join.sql.
UNION ALL SELECT 'crimedrama', count(*) FROM (
    SELECT movie_id FROM has_genre WHERE genre_id = 6
    INTERSECT
    SELECT movie_id FROM has_genre WHERE genre_id = 8);
