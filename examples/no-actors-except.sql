-- name: Movies with no actors, via EXCEPT, for the solution to q:no-actors-except
-- headers: auto
-- tt: movie_id
-- The query is code/no-actors-except.sql, with ORDER BY added to pin the row order.
-- Must come out byte-identical to no-actors.tex: the exercise is to get the same answer
-- as q:no-actors a different way. Both columns are needed, since EXCEPT compares whole
-- rows and titles are not unique -- see the solution.
SELECT movie_id, title FROM movies
EXCEPT
SELECT movie_id, title FROM movies JOIN plays_role USING (movie_id)
ORDER BY title;
