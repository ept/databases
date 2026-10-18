MATCH (m:Movie)
WHERE 'Romance' IN m.genres AND 'Comedy' IN m.genres
RETURN count(m);
