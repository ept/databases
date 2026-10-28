MATCH (p:Place)-[:LOCATED_IN*]->(c:Place)
WHERE NOT EXISTS { (c)-[:LOCATED_IN]->(:Place) }
WITH p, count(DISTINCT c) AS continents
WHERE continents > 1
RETURN DISTINCT p.name;
