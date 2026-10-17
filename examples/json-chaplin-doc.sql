-- name: Charles Chaplin's document in the people table, abridged, for s:json-person
-- format: json
-- maxitems: acted_in=2
-- omit: directed, produced, wrote, composed_for
SELECT data FROM people WHERE (data->>'name') = 'Charles Chaplin';
