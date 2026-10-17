SELECT   data->>'name' AS name,
         json_array_length(data, '$.directed') AS n_movies
FROM     people
ORDER BY n_movies DESC, name
LIMIT    5;
