-- name: The has_genre excerpt read out in words, for the foreign key slide
-- format: list
-- template: ``{title}'' is {genres}
-- separator: ;
-- Describes exactly the rows of fk-has-genre.sql, so the two must be kept in step: same
-- movies, same genres. The inner query is ordered because SQLite 3.40 does not accept an
-- ORDER BY inside group_concat, and the concatenated genres should be in a fixed order.
SELECT title, group_concat(name, ' and ') AS genres
FROM (
    SELECT m.movie_id, m.title, m.year, g.name
    FROM has_genre h
    JOIN movies m USING (movie_id)
    JOIN genres g USING (genre_id)
    WHERE h.movie_id IN ('tt0078748', 'tt0120338', 'tt6751668')
      AND h.genre_id IN (8, 21, 22)
    ORDER BY m.year, g.genre_id
)
GROUP BY movie_id
ORDER BY year;
