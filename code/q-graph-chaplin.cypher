MATCH (m:Movie) <-[:DIRECTED]- (p:Person {name: 'Charles Chaplin'}) -[:ACTED_IN]-> (m)
RETURN m.title, m.year
ORDER BY m.year, m.title;
