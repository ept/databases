-- name: Result of the three-table join on s:multi-join
-- headers: auto
-- The query is code/sql-join3.sql; keep the two in step.
-- ORDER BY role is what makes the row order deterministic, and it happens to put
-- Chaplin's own part first. The Kid is the running example from s:moviedb-kid1.
SELECT   m.title, r.role, p.name
FROM     movies AS m
JOIN     plays_role AS r ON m.movie_id = r.movie_id
JOIN     people AS p ON r.person_id = p.person_id
WHERE    m.title = 'The Kid'
ORDER BY r.role
LIMIT    4;
