SELECT   data->>'title' AS title, data->>'year' AS year
FROM     movies
WHERE    list_contains(data->>'$.actors[*].name', 'Charles Chaplin')
ORDER BY year;
