// name: Labels for the diagram of part of the graph on s:graph-kid
// format: macros
// prefix: graphkid
// The MATCH requires every vertex and edge that the diagram draws, so if any of them
// disappears from the data, the query returns nothing and the build fails (rather than
// the diagram showing an edge that no longer exists).
MATCH (k:Movie {title: 'The Kid', year: 1921})<-[ck:ACTED_IN]-(c:Person {name: 'Charles Chaplin'}),
      (c)-[cg:ACTED_IN]->(g:Movie {title: 'The Gold Rush'}),
      (k)<-[jk:ACTED_IN]-(j:Person {name: 'Jackie Coogan'}),
      (k)<-[:DIRECTED]-(c)
WITH {kidtitle: k.title, kidyear: k.year, rushtitle: g.title, rushyear: g.year,
      chaplin: c.name, chaplinborn: c.birthyear, coogan: j.name, cooganborn: j.birthyear,
      chaplinkidroles: ck.roles, chaplinrushroles: cg.roles, cooganroles: jk.roles} AS facts
UNWIND keys(facts) AS name
RETURN name, facts[name] AS value;
