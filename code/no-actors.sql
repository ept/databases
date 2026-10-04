SELECT    m.title
FROM      movies AS m
LEFT JOIN plays_role AS r ON m.movie_id = r.movie_id
WHERE     r.person_id IS NULL
ORDER BY  m.title;
