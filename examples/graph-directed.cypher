// name: Result of the Cypher query on s:cypher-edges
// headers: auto
// The query is code/graph-directed.cypher; keep the two identical. code/graph-directed.sql
// is the SQL equivalent, which returns the same rows.
MATCH (p:Person {name: 'Steven Spielberg'})
      -[:DIRECTED]->(m:Movie)
RETURN m.title, m.year
ORDER BY m.year
LIMIT 4;
