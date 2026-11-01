WITH RECURSIVE costar(a, b) AS (
    SELECT x.person_id, y.person_id
    FROM   has_position AS x
    JOIN   has_position AS y USING (movie_id)
    WHERE  x.position = 'actor' AND y.position = 'actor'
      AND  x.person_id <> y.person_id
), distance(person_id, d) AS (
    SELECT person_id, 0 FROM people WHERE name = 'Kevin Bacon'
    UNION
    SELECT b, d + 1
    FROM   distance
    JOIN   costar ON a = person_id
    WHERE  d < 10
), bacon(person_id, n) AS (
    SELECT person_id, MIN(d) FROM distance GROUP BY person_id
)
SELECT n AS bacon_number, COUNT(*) AS people
FROM   bacon
GROUP BY n;
