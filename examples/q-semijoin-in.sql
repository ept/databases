-- name: Result of the IN form in the solution to q:semijoin-without-exists
-- headers: auto
-- maxrows: 4
-- The query is code/q-semijoin-in.sql, with ORDER BY added to pin the excerpt.
-- Must come out byte-identical to sql-exists.tex: the exercise is to get the same
-- answer as the EXISTS query on s:semijoin without using EXISTS.
SELECT name FROM people
WHERE person_id IN (
    SELECT person_id FROM has_position
    WHERE position = 'composer'
)
ORDER BY name;
