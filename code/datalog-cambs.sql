WITH RECURSIVE in_cambs(place_id) AS (
    SELECT place_id FROM places
    WHERE  name = 'Cambridgeshire'
    UNION
    SELECT l.place_id
    FROM   located_in AS l
    JOIN   in_cambs AS c ON l.parent_id = c.place_id
)
SELECT DISTINCT m.title, m.year
FROM   in_cambs AS c
JOIN   filmed_at AS f ON f.place_id = c.place_id
JOIN   movies AS m ON m.movie_id = f.movie_id;
