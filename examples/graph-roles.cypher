// name: Result of the query with relationship properties on s:cypher-edges
// headers: auto
// The query is code/graph-roles.cypher; keep the two identical.
MATCH (p:Person)-[r:ACTED_IN]->
      (m:Movie {title: 'The Kid'})
RETURN p.name, r.roles
ORDER BY p.name
LIMIT 4;
