-- name: The genres rows referenced by The Kid
-- headers: auto
SELECT g.genre_id, g.name
FROM genres g
WHERE g.genre_id IN (
    SELECT hg.genre_id FROM has_genre hg JOIN movies m USING (movie_id)
    WHERE m.title = 'The Kid' AND m.year = 1921
)
ORDER BY g.genre_id;
