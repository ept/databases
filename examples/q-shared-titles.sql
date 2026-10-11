-- name: Titles shared by more than one movie, for the solution to q:shared-titles
-- headers: auto
-- maxrows: 4
-- The query is code/q-shared-titles.sql, with ORDER BY added to pin the excerpt.
-- The row count must equal qcountsharedtitles, which q:no-actors-except also quotes.
SELECT title FROM movies
GROUP BY title
HAVING count(*) > 1
ORDER BY title;
