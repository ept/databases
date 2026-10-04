-- Insert a new row into a table
INSERT INTO genres (genre_id, name)
VALUES (27, 'Superhero');

-- Modify existing rows in a table
UPDATE movies
SET    minutes = 117
WHERE  movie_id = 'tt0078748';

-- Delete rows from a table
DELETE FROM movies
WHERE year < 1900;
