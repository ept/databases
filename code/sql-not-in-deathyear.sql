-- Which movies came out in a year in which none
-- of the people in the database died?
SELECT title FROM movies
WHERE year NOT IN (SELECT deathyear FROM people)
