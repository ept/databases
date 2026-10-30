MATCH (c:Place {name: 'Cambridgeshire'})
      <-[:LOCATED_IN*0..]- (p:Place)
      <-[:FILMED_AT]- (m:Movie)
RETURN DISTINCT m.title, m.year, p.name AS place;
