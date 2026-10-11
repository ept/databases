-- name: Result of the EXISTS semijoin on s:semijoin
-- headers: auto
-- maxrows: 4
-- The query is code/sql-exists.sql, with ORDER BY added to pin the excerpt.
-- The row count must equal qcountcomposers, and must be well below
-- qcountcomposercredits: that gap is the point of the slide.
SELECT name FROM people AS p
WHERE EXISTS (
    SELECT 1 FROM has_position AS hp
    WHERE hp.person_id = p.person_id
      AND hp.position = 'composer'
)
ORDER BY name;
