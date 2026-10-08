-- name: Counts showing that a condition and its negation do not partition a table
-- format: macros
-- prefix: nullp
-- thousands: n
-- For the nulls discussion in sec:set-multiset. died and notdied must add up to less
-- than people, the shortfall being unknown: rows where deathyear is null satisfy
-- neither the condition nor its negation. If a refresh ever makes them add up, the
-- prose claim is wrong and the example needs a different column.
SELECT 'people' AS name, count(*) AS n FROM people
UNION ALL SELECT 'died', count(*) FROM people WHERE deathyear < 2000
UNION ALL SELECT 'notdied', count(*) FROM people WHERE NOT (deathyear < 2000)
UNION ALL SELECT 'unknown', count(*) FROM people WHERE deathyear IS NULL;
