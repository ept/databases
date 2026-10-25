WITH RECURSIVE costar(a, b) AS (
    SELECT x.person_id, y.person_id
    FROM   has_position AS x
    JOIN   has_position AS y ON x.movie_id = y.movie_id
    WHERE  x.position = 'actor' AND y.position = 'actor'
      AND  x.person_id <> y.person_id
), distance(person_id, d) AS (
    SELECT person_id, 0 FROM people WHERE name = 'Kevin Bacon'
    UNION
    SELECT c.b, dist.d + 1
    FROM   distance AS dist JOIN costar AS c ON c.a = dist.person_id
    WHERE  dist.d < 10
), bacon(person_id, n) AS (
    SELECT person_id, MIN(d) FROM distance GROUP BY person_id
)
SELECT n AS bacon_number, COUNT(*) AS people
FROM   bacon
WHERE  n > 0
GROUP BY n;
