-- name: The places added to in_cambs in each iteration of evaluating it, on s:recursion-iterations
-- format: list
-- separator:
-- template: \iterationline{{iteration}}{{places}}
-- Iteration k adds the places whose shortest chain of located_in up to Cambridgeshire has
-- k - 1 links: the ones that it can reach from the places added in iteration k - 1, and
-- that are not already there. \iterationline is defined in setup.tex.
WITH RECURSIVE in_cambs(place_id, depth) AS (
    SELECT place_id, 0 FROM places WHERE name = 'Cambridgeshire'
    UNION ALL
    SELECT l.place_id, c.depth + 1
    FROM   located_in AS l JOIN in_cambs AS c ON l.parent_id = c.place_id
), shortest AS (
    SELECT place_id, min(depth) AS depth FROM in_cambs GROUP BY place_id
)
SELECT s.depth + 1 AS iteration, string_agg(p.name, ', ' ORDER BY p.name) AS places
FROM   shortest AS s JOIN places AS p ON p.place_id = s.place_id
GROUP BY s.depth
ORDER BY s.depth;
