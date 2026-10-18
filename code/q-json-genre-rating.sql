SELECT   genre,
         round(avg((movie->>'rating')::DOUBLE), 2) AS avg_rating
FROM     movies, unnest(movie->>'$.genres[*]') AS t(genre)
GROUP BY genre
ORDER BY avg_rating DESC, genre
LIMIT    5;
