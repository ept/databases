-- name: Charles Chaplin's rows in has_position for The Kid
-- tt: person_id, movie_id
-- maxrows: 6
SELECT hp.person_id, hp.movie_id, hp.position, hp.job
FROM has_position hp
JOIN movies m USING (movie_id)
JOIN people p USING (person_id)
WHERE m.title = 'The Kid' AND m.year = 1921 AND p.name = 'Charles Chaplin'
ORDER BY hp.position;
