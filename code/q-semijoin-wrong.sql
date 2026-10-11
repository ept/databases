SELECT DISTINCT p.name
FROM   people AS p
JOIN   has_position AS hp USING (person_id)
WHERE  hp.position = 'composer';
