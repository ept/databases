-- People who have composed music for a movie
SELECT COUNT(*) FROM people
WHERE  json_exists(person, '$.composed_for');

-- People who have never acted
SELECT COUNT(*) FROM people
WHERE  NOT json_exists(person, '$.acted_in');
