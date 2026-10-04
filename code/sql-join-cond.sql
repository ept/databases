SELECT    m.title, p.name
FROM      movies AS m
LEFT JOIN has_position AS hp ON m.movie_id = hp.movie_id
                            AND hp.position = 'composer'
LEFT JOIN people AS p USING (person_id)
WHERE     m.year = 1977
ORDER BY  m.title;
