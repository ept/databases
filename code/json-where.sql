SELECT data->>'title' AS title, data->>'year' AS year
FROM   movies
WHERE  (data->>'title') LIKE 'Star Wars%'
  AND  (data->>'year')::INTEGER >= 2000
ORDER BY year;
