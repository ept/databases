SELECT h1.movie_id
FROM   has_genre AS h1
JOIN   genres AS g1 ON g1.genre_id = h1.genre_id
JOIN   has_genre AS h2 ON h2.movie_id = h1.movie_id
JOIN   genres AS g2 ON g2.genre_id = h2.genre_id
WHERE  g1.name = 'Crime' AND g2.name = 'Drama';
