// name: Result of the Bacon number query on s:bacon
// headers: auto
// thousands: people
// The query is code/graph-bacon.cypher; keep the two identical. It takes about a minute
// in the single-threaded engine that render.py uses.
MATCH path = allShortestPaths(
        (kb:Person {name: 'Kevin Bacon'})
        -[:ACTED_IN*]-
        (p:Person))
WHERE p.person_id <> kb.person_id
RETURN length(path) / 2 AS bacon_number,
       count(DISTINCT p.person_id) AS people
ORDER BY bacon_number;
