SELECT movie_id, title
FROM   movies
WHERE NOT EXISTS (
    SELECT 1 FROM plays_role
    WHERE plays_role.movie_id = movies.movie_id
);
