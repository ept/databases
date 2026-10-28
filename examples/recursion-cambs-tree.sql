-- name: The places within Cambridgeshire as a tree, with the movies filmed at each, on s:cambs-tree
-- format: list
-- separator:
-- template: \placeline{{depth}}{{line}}{{parent}}{{name}}{{movies}}
-- One line per path from Cambridgeshire, in depth-first order, so that a place within two
-- places of the tree appears under both. line numbers the lines from 1, and parent is the
-- line of the place it is directly within (0 for Cambridgeshire), so that \placeline
-- (defined in setup.tex) can draw the lines of the tree from each place to its parent.
WITH RECURSIVE tree(place_id, depth, path) AS (
    SELECT place_id, 0, [name] FROM places WHERE name = 'Cambridgeshire'
    UNION ALL
    SELECT l.place_id, t.depth + 1, list_append(t.path, p.name)
    FROM   located_in AS l
    JOIN   tree AS t ON l.parent_id = t.place_id
    JOIN   places AS p ON p.place_id = l.place_id
), lines AS (
    SELECT t.*, row_number() OVER (ORDER BY t.path) AS line FROM tree AS t
)
SELECT l.depth, l.line, coalesce(parent.line, 0) AS parent, p.name,
       coalesce((SELECT string_agg(m.title, ', ' ORDER BY m.title)
                 FROM   filmed_at AS f JOIN movies AS m ON m.movie_id = f.movie_id
                 WHERE  f.place_id = l.place_id), '') AS movies
FROM   lines AS l
JOIN   places AS p ON p.place_id = l.place_id
LEFT JOIN lines AS parent ON parent.path = l.path[1:len(l.path) - 1]
ORDER BY l.line;
