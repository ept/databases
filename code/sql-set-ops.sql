SELECT movie_id FROM has_genre WHERE genre_id = 6
INTERSECT                       -- 6 = Crime, 8 = Drama
SELECT movie_id FROM has_genre WHERE genre_id = 8;
