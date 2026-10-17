SELECT   data->>'title' AS title, data->>'year' AS year
FROM     movies
WHERE    list_has_any(data->>'$.directors[*].person_id',
                      data->>'$.actors[*].person_id')
ORDER BY (data->>'rating')::DOUBLE DESC, title
LIMIT    5;
