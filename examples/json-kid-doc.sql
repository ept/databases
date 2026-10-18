-- name: The Kid's document in the movies table, abridged, for s:json-movie
-- format: json
-- maxitems: actors=1, trivia_entries=0
-- omit: directors, producers, writers, composers
SELECT movie FROM movies
WHERE (movie->>'title') = 'The Kid' AND (movie->>'year')::INTEGER = 1921;
