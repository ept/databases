-- name: Result of part 2 of q:ra-translate
-- headers: auto
-- maxrows: 4
-- The solution shows code/q-ra4.sql, which has no outer ORDER BY; it is added here only
-- to make the truncated excerpt deterministic. The ORDER BY *inside* string_agg is part
-- of the query proper, and is what fixes the order of names within each string.
SELECT title, string_agg(name, ', ' ORDER BY name) AS genres
FROM   movies
JOIN   has_genre USING (movie_id)
JOIN   genres USING (genre_id)
GROUP BY movie_id, title
ORDER BY title;
