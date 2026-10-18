-- name: Charles Chaplin's document in the people table, abridged, for s:json-person
-- format: json
-- maxitems: acted_in=2
-- omit: directed, produced, wrote, composed_for
SELECT person FROM people WHERE (person->>'name') = 'Charles Chaplin';
