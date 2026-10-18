SELECT   m.title, m.year
FROM     people AS p
JOIN     has_position AS hp ON hp.person_id = p.person_id
JOIN     movies AS m ON m.movie_id = hp.movie_id
WHERE    p.name = 'Steven Spielberg'
  AND    hp.position = 'director'
ORDER BY m.year
LIMIT    4;
