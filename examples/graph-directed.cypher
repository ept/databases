// name: Result of the Cypher query on s:cypher-edges
// headers: auto
// The query is code/graph-directed.cypher; keep the two identical. s:cypher-vs-sql shows
// the same query without ORDER BY and LIMIT (code/graph-directed-short.cypher) next to its
// SQL equivalent (code/graph-directed.sql); the two return the same rows.
MATCH (p:Person {name: 'Steven Spielberg'})
      -[:DIRECTED]-> (m:Movie)
RETURN m.title, m.year
ORDER BY m.year
LIMIT 4;
