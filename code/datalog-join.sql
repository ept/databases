SELECT p.name, r.role
FROM   movies AS m
JOIN   plays_role AS r ON m.movie_id = r.movie_id
JOIN   people AS p ON r.person_id = p.person_id
WHERE  m.title = 'The Kid';
