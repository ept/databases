-- name: Charles Chaplin's rows in plays_role for The Kid
-- headers: auto
-- tt: person_id, movie_id
SELECT pr.person_id, pr.movie_id, pr.role
FROM plays_role pr
JOIN movies m USING (movie_id)
JOIN people p USING (person_id)
WHERE m.title = 'The Kid' AND m.year = 1921 AND p.name = 'Charles Chaplin'
ORDER BY pr.role;
