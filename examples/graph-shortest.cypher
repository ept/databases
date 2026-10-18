// name: Result of the shortest-path query on s:shortest-path
// headers: auto
// The query is code/graph-shortest.cypher; keep the two identical. If several paths are
// equally short, the engine returns one of them, so a new version of Traverse could pick
// a different one; the prose does not name the people along the path.
MATCH path = shortestPath(
        (a:Person {name: 'Jennifer Lawrence'})
        -[:ACTED_IN*]-
        (b:Person {name: 'Daniel Radcliffe'}))
WITH nodes(path) AS vs
UNWIND range(0, size(vs) - 1) AS i
RETURN i AS step,
       coalesce(vs[i].name, vs[i].title) AS vertex
ORDER BY step;
