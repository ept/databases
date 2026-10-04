-- name: Result of the compound join condition on s:join-condition
-- headers: auto
-- The query is code/sql-join-cond.sql; keep the two identical, ORDER BY included.
-- 1977 is chosen because it is a year with only three movies in the database and a
-- genuine mix: two have a composer recorded and Annie Hall has none, which is correct
-- rather than a gap -- the film uses source music and has no original score.
-- If a refresh changes that, look for another year with a small mix (1939 and 1967 also
-- worked when this was written).
SELECT    m.title, p.name AS composer_name
FROM      movies AS m
LEFT JOIN has_position AS hp ON m.movie_id = hp.movie_id
                            AND hp.position = 'composer'
LEFT JOIN people AS p USING (person_id)
WHERE     m.year = 1977
ORDER BY  m.title;
