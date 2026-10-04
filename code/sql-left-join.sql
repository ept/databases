SELECT    m.title, r.role, p.name
FROM      movies AS m
LEFT JOIN plays_role AS r ON m.movie_id = r.movie_id
LEFT JOIN people AS p ON r.person_id = p.person_id
WHERE     m.title IN ('Arctic', 'Flow')
ORDER BY  m.title, p.name;
