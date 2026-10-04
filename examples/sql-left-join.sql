-- name: Result of the left join on s:left-join
-- headers: auto
-- The query is code/sql-left-join.sql; keep the two in step.
-- The two titles are picked so the whole result fits on a slide: Arctic has a cast of
-- three, and Flow (dialogue-free animation) is one of only two movies in the dataset
-- with no plays_role rows at all, so it is the row that shows the null.
-- If a refresh makes Flow gain a cast, pick another movie with none.
SELECT    m.title, p.name
FROM      movies AS m
LEFT JOIN plays_role AS r ON m.movie_id = r.movie_id
LEFT JOIN people AS p ON r.person_id = p.person_id
WHERE     m.title IN ('Arctic', 'Flow')
ORDER BY  m.title, p.name;
