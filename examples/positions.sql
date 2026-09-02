-- name: The distinct values of has_position.position, most common first
-- format: list
-- tt: position
-- conjunction: or
SELECT position FROM has_position GROUP BY position ORDER BY count(*) DESC;
