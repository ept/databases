-- name: Movies with no actors, for the solution to q:no-actors
-- headers: auto
-- The query is code/no-actors.sql; keep the two in step.
-- This is the anti-join idiom: left join, then keep only the rows where the right
-- side failed to match. If a refresh leaves every movie with a cast, the result is
-- empty and render.py will fail rather than print an empty table -- in that case the
-- exercise needs rethinking, since it would no longer have an interesting answer.
SELECT    m.title
FROM      movies AS m
LEFT JOIN plays_role AS r ON m.movie_id = r.movie_id
WHERE     r.person_id IS NULL
ORDER BY  m.title;
