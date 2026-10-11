SELECT name FROM people AS p
WHERE EXISTS (
    SELECT 1 FROM has_position AS hp
    WHERE hp.person_id = p.person_id
      AND hp.position = 'composer'
);
