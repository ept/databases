-- name: Result of the trivia search on s:json-text
-- headers: auto
-- maxrows: 5
-- The query is code/json-text.sql; keep the two in step.
SELECT movie->>'title' AS title, movie->>'year' AS year
FROM   movies
WHERE  EXISTS (
    SELECT 1
    FROM   unnest(movie->>'$.trivia_entries[*]') AS t(e)
    WHERE  e ILIKE '%hacker%'
)
ORDER BY title;
