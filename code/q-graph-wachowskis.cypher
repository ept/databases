MATCH (lana:Person {name: 'Lana Wachowski'})-->(m:Movie),
      (lilly:Person {name: 'Lilly Wachowski'})-->(m)
RETURN DISTINCT m.title, m.year
ORDER BY m.year, m.title;
