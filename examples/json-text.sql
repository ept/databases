-- name: Result of the trivia search on s:json-text
-- headers: auto
-- maxrows: 5
-- The query is code/json-text.sql; keep the two in step.
SELECT data->>'title' AS title, data->>'year' AS year
FROM   movies
WHERE  EXISTS (
    SELECT 1
    FROM   unnest(data->>'$.trivia_entries[*]') AS t(e)
    WHERE  e ILIKE '%hacker%'
)
ORDER BY title;
