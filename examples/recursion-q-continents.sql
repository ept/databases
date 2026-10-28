-- name: The countries in more than one continent, in the solution to q:recursion-continents
-- format: list
-- conjunction: and
SELECT p.name
FROM   located_in AS l
JOIN   places AS p ON p.place_id = l.place_id
WHERE  l.parent_id NOT IN (SELECT place_id FROM located_in)
GROUP BY p.place_id, p.name
HAVING count(*) > 1
ORDER BY p.name;
