-- name: The most-shared name among actors, for the solution to q:semijoin-without-exists
-- format: list
-- template: {n} different people are credited as actors under the name ``{name}''
-- Concrete evidence that deduplicating on the name loses people. Composers have no such
-- collision, which is why the solution switches to actors to make the point.
SELECT p.name, count(DISTINCT p.person_id) AS n
FROM   people AS p
JOIN   has_position AS hp USING (person_id)
WHERE  hp.position = 'actor'
GROUP BY p.name
HAVING count(DISTINCT p.person_id) > 1
ORDER BY n DESC, p.name
LIMIT 1;
