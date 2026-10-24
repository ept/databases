MATCH (p:Person) -[r:ACTED_IN]->
      (m:Movie {title: 'The Kid'})
RETURN p.name, r.roles
ORDER BY p.name
LIMIT 4;
