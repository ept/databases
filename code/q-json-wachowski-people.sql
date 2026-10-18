SELECT DISTINCT c->>'movie_id' AS movie_id,
                c->>'title'    AS title,
                c->>'year'     AS year
FROM     people, unnest(person->'$.*[*]') AS t(c)
WHERE    (person->>'name') = 'Lana Wachowski'
ORDER BY year, title;
