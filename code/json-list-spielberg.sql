SELECT data->>'title' AS title, data->>'year' AS year
FROM   movies
WHERE  list_contains(data->>'$.directors[*].name',
                     'Steven Spielberg')
ORDER BY year
LIMIT  3;
