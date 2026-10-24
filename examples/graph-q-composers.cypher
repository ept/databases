// name: Result of code/q-graph-composers.cypher, for the solution to q:cypher-queries
// headers: auto
// The query is code/q-graph-composers.cypher; keep the two identical.
MATCH (p:Person) -[:COMPOSED_FOR]-> (m:Movie)
RETURN p.name, count(m) AS movies
ORDER BY movies DESC, p.name
LIMIT 5;
