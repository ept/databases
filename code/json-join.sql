SELECT   a->>'name' AS name,
         (m.data->>'year')::INTEGER
           - (p.data->>'birthyear')::INTEGER AS age
FROM     movies AS m, unnest(m.data->'$.actors[*]') AS t(a),
         people AS p
WHERE    p.person_id = (a->>'person_id')
  AND    (m.data->>'title') = 'The Kid'
ORDER BY age DESC, name
LIMIT    4;
