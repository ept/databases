-- name: How many (movie, person) pairs play more than one character
-- format: scalar
-- thousands: n
SELECT count(*) AS n FROM (
    SELECT movie_id, person_id FROM plays_role
    GROUP BY movie_id, person_id HAVING count(*) > 1
);
