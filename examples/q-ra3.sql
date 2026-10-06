-- name: Result of part 3 of q:ra-translate
-- headers: auto
-- maxrows: 4
-- The solution shows code/q-ra3.sql; ORDER BY is added here only to make the truncated
-- excerpt deterministic. These rows show one movie appearing once per genre, which is
-- the point the solution makes about the result being a relation, not a list of movies.
SELECT title, name FROM movies
JOIN has_genre ON movies.movie_id = has_genre.movie_id
JOIN genres ON has_genre.genre_id = genres.genre_id
ORDER BY title, name;
