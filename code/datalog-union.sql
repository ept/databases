SELECT movie_id
FROM   has_genre JOIN genres USING (genre_id)
WHERE  name = 'Crime'
UNION
SELECT movie_id
FROM   has_genre JOIN genres USING (genre_id)
WHERE  name = 'Drama';
