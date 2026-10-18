MATCH (m:Movie)
WHERE m.title = 'The Kid' AND m.year = 1921
RETURN m.title, m.year, m.genres;
