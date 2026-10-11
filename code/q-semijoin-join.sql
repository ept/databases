SELECT p.name
FROM   people AS p
JOIN  (SELECT DISTINCT person_id FROM has_position
       WHERE position = 'composer') AS c
       USING (person_id);
