-- name: Result of part 1 of q:ra-translate
-- headers: auto
-- maxrows: 4
-- The solution shows code/q-ra1.sql, which has no ORDER BY; it is added here only to
-- make the truncated excerpt deterministic. Keep the two in step otherwise.
SELECT title FROM movies WHERE year = 1995 ORDER BY title;
