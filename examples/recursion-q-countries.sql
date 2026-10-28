-- name: The countries in which the most movies were filmed, in the solution to q:recursion-countries
-- headers: Country, Movies
-- thousands: movies
-- The query of code/q-recursion-countries.sql, with ORDER BY and LIMIT.
WITH RECURSIVE within(place_id, area_id) AS (
    SELECT place_id, parent_id FROM located_in
    UNION
    SELECT l.place_id, w.area_id
    FROM   located_in AS l
    JOIN   within AS w ON l.parent_id = w.place_id
), filmed_within(movie_id, area_id) AS (
    SELECT movie_id, place_id FROM filmed_at
    UNION
    SELECT f.movie_id, w.area_id
    FROM   filmed_at AS f
    JOIN   within AS w ON f.place_id = w.place_id
), countries(place_id) AS (
    SELECT DISTINCT place_id FROM located_in
    WHERE  parent_id NOT IN (SELECT place_id FROM located_in)
)
SELECT p.name AS country, count(*) AS movies
FROM   countries AS c
JOIN   places AS p ON p.place_id = c.place_id
JOIN   filmed_within AS i ON i.area_id = c.place_id
GROUP BY p.place_id, p.name
ORDER BY movies DESC, country
LIMIT 5;
