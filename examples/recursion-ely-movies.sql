-- name: The movies filmed at Ely Cathedral, on s:filming-locations
-- format: list
-- template: \emph{{title}} ({year})
-- conjunction: and
SELECT m.title, m.year
FROM   places AS p
JOIN   filmed_at AS f ON f.place_id = p.place_id
JOIN   movies AS m ON m.movie_id = f.movie_id
WHERE  p.name = 'Ely Cathedral'
ORDER BY m.title;
