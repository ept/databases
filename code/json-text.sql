SELECT movie->>'title' AS title, movie->>'year' AS year
FROM   movies
WHERE  EXISTS (
    SELECT 1
    FROM   unnest(movie->>'$.trivia_entries[*]') AS t(e)
    WHERE  e ILIKE '%hacker%'
)
ORDER BY title;
