SELECT   c->>'title' AS title, c->>'year' AS year
FROM     people, unnest(data->'$.acted_in[*]') AS t(c)
WHERE    (data->>'name') = 'Charles Chaplin'
ORDER BY year;
