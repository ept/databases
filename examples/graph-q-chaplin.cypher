// name: Result of code/q-graph-chaplin.cypher, for the solution to q:cypher-queries
// headers: auto
// The query is code/q-graph-chaplin.cypher; keep the two identical.
MATCH (m:Movie)<-[:DIRECTED]-(p:Person {name: 'Charles Chaplin'})-[:ACTED_IN]->(m)
RETURN m.title, m.year
ORDER BY m.year, m.title;
