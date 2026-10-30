SELECT name, role
FROM   movies
JOIN   plays_role USING (movie_id)
JOIN   people USING (person_id)
WHERE  title = 'The Kid';
