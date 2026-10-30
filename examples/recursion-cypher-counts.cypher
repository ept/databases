// name: Counts from the Cypher version of the Cambridgeshire query, for the notes
// format: macros
// prefix: rec
// The query of code/datalog-cambs.cypher without DISTINCT: one row for each path, so a
// movie filmed at a place that is within Cambridgeshire along two paths appears twice.
MATCH (c:Place {name: 'Cambridgeshire'})
      <-[:LOCATED_IN*0..]- (p:Place)
      <-[:FILMED_AT]- (m:Movie)
WITH count(*) AS n
RETURN 'cypherrows' AS name, n;
