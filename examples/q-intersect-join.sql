-- name: Result of the self-join in the solution to q:intersect-join
-- headers: auto
-- tt: movie_id
-- maxrows: 4
-- The query is code/q-intersect-join.sql; ORDER BY is added here only to make the
-- truncated excerpt deterministic. It must return exactly the same rows as
-- code/sql-set-ops.sql, which is the point of the exercise.
SELECT g1.movie_id
FROM   has_genre AS g1
JOIN   has_genre AS g2 USING (movie_id)
WHERE  g1.genre_id = 6 AND g2.genre_id = 8
ORDER BY g1.movie_id;
