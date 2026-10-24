MATCH (:Genre {name: 'Romance'}) <-[:HAS_GENRE]- (m:Movie)
      -[:HAS_GENRE]-> (:Genre {name: 'Comedy'})
RETURN count(m);
