SELECT   a->>'name' AS name, a->'roles' AS roles
FROM     movies, unnest(movie->'$.actors[*]') AS t(a)
WHERE    (movie->>'title') = 'The Kid'
ORDER BY name
LIMIT    4;
