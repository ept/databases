WITH RECURSIVE within(place_id, area_id) AS (
    SELECT place_id, parent_id FROM located_in
    UNION
    SELECT located_in.place_id, area_id
    FROM   located_in
    JOIN   within ON parent_id = within.place_id
), filmed_within(movie_id, area_id) AS (
    SELECT movie_id, place_id FROM filmed_at
    UNION
    SELECT movie_id, area_id
    FROM   filmed_at
    JOIN   within USING (place_id)
), countries(place_id) AS (
    SELECT DISTINCT place_id FROM located_in
    WHERE  parent_id NOT IN (SELECT place_id FROM located_in)
)
SELECT name AS country, count(*) AS movies
FROM   countries
JOIN   places USING (place_id)
JOIN   filmed_within ON area_id = place_id
GROUP BY place_id, name;
