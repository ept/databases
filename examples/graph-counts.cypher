// name: Counts over the graph quoted in the notes, slides and solutions
// format: macros
// prefix: graph
// thousands: n
MATCH (m:Movie) WITH count(m) AS n RETURN 'movies' AS name, n
UNION ALL MATCH (p:Person) WITH count(p) AS n RETURN 'people' AS name, n
UNION ALL MATCH () -[r]-> () WITH count(r) AS n RETURN 'edges' AS name, n
UNION ALL MATCH (p:Person) WHERE (p) -[:ACTED_IN]-> () WITH count(p) AS n RETURN 'actors' AS name, n
// Each count is computed in a WITH, because a literal in RETURN is a grouping key, and a
// group with no rows produces no output row; pathstwo would then be missing, not 0.
// For s:var-length: the number of paths of 2, 4 and 6 ACTED_IN edges between the two
// actors of code/graph-varlength.cypher. The prose adds that the two have not appeared in
// the same movie only when pathstwo is 0 (with \ifdefstring, since the counts are
// formatted with thousands separators and are not necessarily numbers to TeX).
UNION ALL MATCH path = (a:Person {name: 'Jennifer Lawrence'}) -[:ACTED_IN*2]- (b:Person {name: 'Daniel Radcliffe'})
    WITH count(path) AS n RETURN 'pathstwo' AS name, n
UNION ALL MATCH path = (a:Person {name: 'Jennifer Lawrence'}) -[:ACTED_IN*4]- (b:Person {name: 'Daniel Radcliffe'})
    WITH count(path) AS n RETURN 'pathsfour' AS name, n
UNION ALL MATCH path = (a:Person {name: 'Jennifer Lawrence'}) -[:ACTED_IN*6]- (b:Person {name: 'Daniel Radcliffe'})
    WITH count(path) AS n RETURN 'pathssix' AS name, n;
