WITH RECURSIVE in_cambs(place_id) AS (
    SELECT place_id FROM places
    WHERE  name = 'Cambridgeshire'
    UNION
    SELECT located_in.place_id
    FROM   located_in
    JOIN   in_cambs ON parent_id = in_cambs.place_id
)
SELECT title, year, name AS place
FROM   in_cambs
JOIN   places USING (place_id)
JOIN   filmed_at USING (place_id)
JOIN   movies USING (movie_id);
