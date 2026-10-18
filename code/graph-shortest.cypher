MATCH path = shortestPath(
        (a:Person {name: 'Jennifer Lawrence'})
        -[:ACTED_IN*]-
        (b:Person {name: 'Daniel Radcliffe'}))
WITH nodes(path) AS vs
UNWIND range(0, size(vs) - 1) AS i
RETURN i AS step,
       coalesce(vs[i].name, vs[i].title) AS vertex
ORDER BY step;
