-- name: The Kid's row in the ratings table
-- tt: movie_id
-- thousands: votes
SELECT r.movie_id, r.rating, r.votes
FROM ratings r JOIN movies m USING (movie_id)
WHERE m.title = 'The Kid' AND m.year = 1921;
