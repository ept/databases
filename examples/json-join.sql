-- name: Result of the join between documents on s:json-join
-- headers: auto
-- The query is code/json-join.sql; keep the two in step. An actor with no birthyear
-- gets a null age, which DuckDB sorts last, so it cannot push anyone off the slide.
SELECT   a->>'name' AS name,
         (movie->>'year')::INTEGER
           - (person->>'birthyear')::INTEGER AS age
FROM     movies, unnest(movie->'$.actors[*]') AS t(a),
         people
WHERE    person_id = (a->>'person_id')
  AND    (movie->>'title') = 'The Kid'
ORDER BY age DESC, name
LIMIT    4;
