MATCH path = allShortestPaths(
        (kb:Person {name: 'Kevin Bacon'})
        -[:ACTED_IN*]-
        (p:Person))
WHERE p.person_id <> kb.person_id
RETURN length(path) / 2 AS bacon_number,
       count(DISTINCT p.person_id) AS people
ORDER BY bacon_number;
