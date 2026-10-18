MATCH (m:Movie)
UNWIND m.genres AS name
MERGE (g:Genre {name: name})
CREATE (m)-[:HAS_GENRE]->(g);
