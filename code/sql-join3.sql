SELECT   m.title, r.role, p.name
FROM     movies AS m
JOIN     plays_role AS r ON m.movie_id = r.movie_id
JOIN     people AS p ON r.person_id = p.person_id
WHERE    m.title = 'The Kid'
ORDER BY r.role
LIMIT    4;
