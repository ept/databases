MATCH (m:Movie {title: 'The Kid', year: 1921})
RETURN m.title, m.year, m.genres;
