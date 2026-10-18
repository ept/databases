SELECT   c->>'title' AS title, c->>'year' AS year
FROM     people, unnest(person->'$.acted_in[*]') AS t(c)
WHERE    (person->>'name') = 'Charles Chaplin'
ORDER BY year;
