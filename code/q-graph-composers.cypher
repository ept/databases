MATCH (p:Person)-[:COMPOSED_FOR]->(m:Movie)
RETURN p.name, count(m) AS movies
ORDER BY movies DESC, p.name
LIMIT 5;
