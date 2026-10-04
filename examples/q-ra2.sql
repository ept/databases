-- name: Result of part 2 of q:ra-translate
-- headers: auto
-- maxrows: 4
-- The solution shows code/q-ra2.sql; ORDER BY is added here only to make the truncated
-- excerpt deterministic. Longest first, which is the interesting end of this result.
SELECT title, minutes FROM movies WHERE minutes >= 180 ORDER BY minutes DESC, title;
