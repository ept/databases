// name: Result of the first MATCH example on s:cypher-match
// headers: auto
// The query is code/graph-match.cypher; keep the two identical.
MATCH (m:Movie {title: 'The Kid', year: 1921})
RETURN m.title, m.year, m.genres;
