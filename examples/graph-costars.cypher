// name: Result of the co-actor query on s:cypher-costars
// headers: auto
// The query is code/graph-costars.cypher; keep the two identical.
MATCH (p1:Person)-[:ACTED_IN]->(m:Movie)
      <-[:ACTED_IN]-(p2:Person)
WHERE p1.person_id < p2.person_id
RETURN p1.name AS name1, p2.name AS name2,
       count(*) AS movies
ORDER BY movies DESC, name1, name2
LIMIT 5;
