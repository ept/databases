-- name: The places within Cambridgeshire as an indented tree, with the movies filmed at each, on s:cambs-tree
-- format: list
-- separator:
-- template: \placeline{{depth}}{{name}}{{movies}}
-- One line per path from Cambridgeshire, in depth-first order, so that a place within two
-- places of the tree appears under both. \placeline is defined in setup.tex.
WITH RECURSIVE tree(place_id, depth, path) AS (
    SELECT place_id, 0, [name] FROM places WHERE name = 'Cambridgeshire'
    UNION ALL
    SELECT l.place_id, t.depth + 1, list_append(t.path, p.name)
    FROM   located_in AS l
    JOIN   tree AS t ON l.parent_id = t.place_id
    JOIN   places AS p ON p.place_id = l.place_id
)
SELECT t.depth, p.name,
       coalesce(string_agg(m.title, ', ' ORDER BY m.title), '') AS movies
FROM   tree AS t
JOIN   places AS p ON p.place_id = t.place_id
LEFT JOIN filmed_at AS f ON f.place_id = t.place_id
LEFT JOIN movies AS m ON m.movie_id = f.movie_id
GROUP BY t.path, t.depth, p.name
ORDER BY t.path;
