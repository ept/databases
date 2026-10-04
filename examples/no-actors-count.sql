-- name: How many movies have no actors, for the hint in q:no-actors
-- format: list
-- template: {n} {noun}
-- thousands: n
-- The count that code/no-actors.sql returns, so the hint in the question cannot drift
-- away from the answer in the solution. The CASE keeps the noun agreeing with the
-- number if a future dataset has exactly one such movie.
SELECT count(*) AS n,
       CASE WHEN count(*) = 1 THEN 'row' ELSE 'rows' END AS noun
FROM      movies AS m
LEFT JOIN plays_role AS r ON m.movie_id = r.movie_id
WHERE     r.person_id IS NULL;
