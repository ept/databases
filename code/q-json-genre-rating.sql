SELECT   genre,
         round(avg((data->>'rating')::DOUBLE), 2) AS avg_rating
FROM     movies, unnest(data->>'$.genres[*]') AS t(genre)
GROUP BY genre
ORDER BY avg_rating DESC, genre
LIMIT    5;
