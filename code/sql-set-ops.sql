-- Return the IDs of all movies that are both in the
-- Crime (genre_id = 6) and Drama (genre_id = 8) genres
SELECT movie_id FROM has_genre WHERE genre_id = 6
INTERSECT
SELECT movie_id FROM has_genre WHERE genre_id = 8;
