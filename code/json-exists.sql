-- People who have composed music for a movie
SELECT COUNT(*) FROM people
WHERE  json_exists(data, '$.composed_for');

-- People who have never acted
SELECT COUNT(*) FROM people
WHERE  NOT json_exists(data, '$.acted_in');
