SELECT name FROM people
WHERE person_id IN (
    SELECT person_id FROM has_position
    WHERE position = 'composer'
);
