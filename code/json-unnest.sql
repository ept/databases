SELECT   a->>'name' AS name, a->'roles' AS roles
FROM     movies, unnest(data->'$.actors[*]') AS t(a)
WHERE    (data->>'title') = 'The Kid'
ORDER BY name
LIMIT    4;
