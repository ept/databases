SELECT data->>'title' AS title, data->>'year' AS year
FROM   movies
WHERE  EXISTS (
    SELECT 1
    FROM   unnest(data->>'$.trivia_entries[*]') AS t(e)
    WHERE  e ILIKE '%hacker%'
)
ORDER BY title;
