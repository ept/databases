SELECT   a->>'name' AS name,
         (movie->>'year')::INTEGER
           - (person->>'birthyear')::INTEGER AS age
FROM     movies, unnest(movie->'$.actors[*]') AS t(a),
         people
WHERE    person_id = (a->>'person_id')
  AND    (movie->>'title') = 'The Kid'
ORDER BY age DESC, name
LIMIT    4;
