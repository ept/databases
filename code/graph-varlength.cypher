MATCH path = (a:Person {name: 'Jennifer Lawrence'})
             -[:ACTED_IN*4]-
             (b:Person {name: 'Daniel Radcliffe'})
RETURN count(path);
