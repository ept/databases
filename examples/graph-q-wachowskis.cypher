// name: Result of code/q-graph-wachowskis.cypher, for the solution to q:cypher-queries
// headers: auto
// The query is code/q-graph-wachowskis.cypher; keep the two identical.
MATCH (lana:Person {name: 'Lana Wachowski'})-->(m:Movie),
      (lilly:Person {name: 'Lilly Wachowski'})-->(m)
RETURN DISTINCT m.title, m.year
ORDER BY m.year, m.title;
