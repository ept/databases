-- name: The chain of located_in from Ely Cathedral up to its continent, on s:filming-locations
-- format: list
-- separator: \ $\rightarrow$
-- Ely Cathedral has one chain of parents (were it ever to have two, the list would mix them).
WITH RECURSIVE up(place_id, links) AS (
    SELECT place_id, 0 FROM places WHERE name = 'Ely Cathedral'
    UNION
    SELECT l.parent_id, u.links + 1
    FROM   located_in AS l JOIN up AS u ON l.place_id = u.place_id
)
SELECT p.name FROM up JOIN places AS p ON p.place_id = up.place_id
ORDER BY links;
