-- every movie, with its rating where one exists
SELECT title, rating
FROM   movies LEFT JOIN ratings USING (movie_id);
