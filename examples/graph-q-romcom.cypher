// name: Result of code/q-graph-romcom-list.cypher, for the solution to q:genre-nodes
// format: scalar
// thousands: count(m)
// The query is code/q-graph-romcom-list.cypher; keep the two identical.
MATCH (m:Movie)
WHERE 'Romance' IN m.genres AND 'Comedy' IN m.genres
RETURN count(m);
