-- name: The Kid's document in the movies table, abridged, for s:json-movie
-- format: json
-- maxitems: actors=1, trivia_entries=0
-- omit: directors, producers, writers, composers
SELECT data FROM movies
WHERE (data->>'title') = 'The Kid' AND (data->>'year')::INTEGER = 1921;
