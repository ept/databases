WITH RECURSIVE within(place_id, area_id) AS (
    SELECT place_id, parent_id FROM located_in
    UNION
    SELECT l.place_id, w.area_id
    FROM   located_in AS l
    JOIN   within AS w ON l.parent_id = w.place_id
), filmed_in(movie_id, area_id) AS (
    SELECT movie_id, place_id FROM filmed_at
    UNION
    SELECT f.movie_id, w.area_id
    FROM   filmed_at AS f
    JOIN   within AS w ON f.place_id = w.place_id
)
SELECT m.title, m.year
FROM   movies AS m
WHERE  m.movie_id IN (SELECT i.movie_id FROM filmed_in AS i
                      JOIN places AS p ON p.place_id = i.area_id
                      WHERE p.name = 'United Kingdom')
  AND  m.movie_id NOT IN (SELECT i.movie_id FROM filmed_in AS i
                          JOIN places AS p ON p.place_id = i.area_id
                          WHERE p.name = 'England');
