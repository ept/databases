-- name: Result of the join form in the solution to q:semijoin-without-exists
-- headers: auto
-- maxrows: 4
-- The query is code/q-semijoin-join.sql, with ORDER BY added to pin the excerpt.
-- Must come out byte-identical to sql-exists.tex: the exercise is to get the same
-- answer as the EXISTS query on s:semijoin using an inner join instead.
SELECT p.name
FROM   people AS p
JOIN  (SELECT DISTINCT person_id FROM has_position
       WHERE position = 'composer') AS c
       USING (person_id)
ORDER BY p.name;
