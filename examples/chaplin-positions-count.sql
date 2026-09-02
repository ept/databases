-- name: How many positions Charles Chaplin held on The Kid
-- format: scalar
SELECT count(*) AS n
FROM has_position hp
JOIN movies m USING (movie_id)
JOIN people p USING (person_id)
WHERE m.title = 'The Kid' AND m.year = 1921 AND p.name = 'Charles Chaplin';
