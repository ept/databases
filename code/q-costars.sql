SELECT   p1.name AS name1, p2.name AS name2, COUNT(*) AS movies
FROM     has_position AS a1
JOIN     has_position AS a2 ON a2.movie_id = a1.movie_id
JOIN     people AS p1 ON p1.person_id = a1.person_id
JOIN     people AS p2 ON p2.person_id = a2.person_id
WHERE    a1.position = 'actor' AND a2.position = 'actor'
  AND    a1.person_id < a2.person_id
GROUP BY p1.person_id, p2.person_id, p1.name, p2.name
ORDER BY movies DESC, name1, name2
LIMIT    5;
