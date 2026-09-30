-- name: Total number of rows across all seven tables, rounded down for use in prose
-- format: scalar
-- thousands: total
-- Rounded to the nearest thousand: the exact figure is not the point, and a rounded one
-- does not invite the reader to check the arithmetic against the per-table counts.
SELECT cast(round(sum(c) / 1000.0) AS int) * 1000 AS total FROM (
    SELECT count(*) AS c FROM movies
    UNION ALL SELECT count(*) FROM people
    UNION ALL SELECT count(*) FROM genres
    UNION ALL SELECT count(*) FROM ratings
    UNION ALL SELECT count(*) FROM has_genre
    UNION ALL SELECT count(*) FROM has_position
    UNION ALL SELECT count(*) FROM plays_role
);
