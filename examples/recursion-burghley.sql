-- name: The places that Burghley House is directly located in, for the notes and s:filming-locations
-- format: list
-- conjunction: and
SELECT q.name
FROM   places AS p
JOIN   located_in AS l ON l.place_id = p.place_id
JOIN   places AS q ON q.place_id = l.parent_id
WHERE  p.name = 'Burghley House'
ORDER BY q.name;
