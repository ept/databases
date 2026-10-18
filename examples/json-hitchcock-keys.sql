-- name: The keys of Alfred Hitchcock's document, for the prose after s:json-person
-- format: list
-- conjunction: and
-- tt: k
-- The query returns them in the document's own order, which is also the order the
-- generator writes them in; ORDER BY would put them alphabetically instead.
SELECT unnest(json_keys(person)) AS k FROM people WHERE (person->>'name') = 'Alfred Hitchcock';
