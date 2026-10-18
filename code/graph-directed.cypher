MATCH (p:Person {name: 'Steven Spielberg'})
      -[:DIRECTED]->(m:Movie)
RETURN m.title, m.year
ORDER BY m.year
LIMIT 4;
