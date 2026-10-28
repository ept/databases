-- name: Counts about the filming locations, quoted in the notes, slides and solutions
-- format: macros
-- prefix: rec
-- thousands: value
-- Runs against the version of the database with the filming locations (see
-- locations/README.md). in_cambs is the recursive relation of code/datalog-cambs.dl and
-- code/datalog-cambs.sql; within is the transitive closure of code/datalog-within.dl.
WITH RECURSIVE in_cambs(place_id, depth) AS (
    SELECT place_id, 0 FROM places WHERE name = 'Cambridgeshire'
    UNION ALL
    SELECT l.place_id, c.depth + 1
    FROM   located_in AS l JOIN in_cambs AS c ON l.parent_id = c.place_id
), within(place_id, area_id, links) AS (
    SELECT place_id, parent_id, 1 FROM located_in
    UNION ALL
    SELECT l.place_id, w.area_id, w.links + 1
    FROM   located_in AS l JOIN within AS w ON l.parent_id = w.place_id
), filmed_in(movie_id, area_id) AS (
    SELECT movie_id, place_id FROM filmed_at
    UNION
    SELECT f.movie_id, w.area_id FROM filmed_at AS f JOIN within AS w ON f.place_id = w.place_id
)
SELECT 'places' AS name, (SELECT count(*) FROM places) AS value
UNION ALL SELECT 'locatedin', (SELECT count(*) FROM located_in)
UNION ALL SELECT 'filmedat', (SELECT count(*) FROM filmed_at)
UNION ALL SELECT 'filmedmovies', (SELECT count(DISTINCT movie_id) FROM filmed_at)
UNION ALL SELECT 'multiparent', (SELECT count(*) FROM (SELECT place_id FROM located_in
                                 GROUP BY place_id HAVING count(*) > 1))
-- The longest chain of located_in links, from anywhere up to a continent
UNION ALL SELECT 'maxlinks', (SELECT max(links) FROM within)
UNION ALL SELECT 'within', (SELECT count(*) FROM (SELECT DISTINCT place_id, area_id FROM within))
UNION ALL SELECT 'withinpaths', (SELECT count(*) FROM within)
-- Cambridgeshire: its places (with UNION, and with UNION ALL, which keeps one row per path)
UNION ALL SELECT 'cambsplaces', (SELECT count(DISTINCT place_id) FROM in_cambs)
UNION ALL SELECT 'cambsrows', (SELECT count(*) FROM in_cambs)
UNION ALL SELECT 'cambsdepth', (SELECT max(depth) FROM in_cambs)
UNION ALL SELECT 'cambsmovies', (SELECT count(DISTINCT f.movie_id) FROM in_cambs AS c
                                 JOIN filmed_at AS f ON f.place_id = c.place_id)
UNION ALL SELECT 'cambsfilmedat', (SELECT count(*) FROM (SELECT DISTINCT f.movie_id, f.place_id
                                   FROM in_cambs AS c JOIN filmed_at AS f ON f.place_id = c.place_id))
-- code/datalog-within.dl: filmed in the United Kingdom, and of those, not in England
UNION ALL SELECT 'ukmovies', (SELECT count(*) FROM filmed_in AS i JOIN places AS p
                              ON p.place_id = i.area_id WHERE p.name = 'United Kingdom')
UNION ALL SELECT 'englandmovies', (SELECT count(*) FROM filmed_in AS i JOIN places AS p
                                   ON p.place_id = i.area_id WHERE p.name = 'England')
UNION ALL SELECT 'uknotengland', (SELECT count(*) FROM (
    SELECT movie_id FROM filmed_in JOIN places ON place_id = area_id WHERE name = 'United Kingdom'
    EXCEPT
    SELECT movie_id FROM filmed_in JOIN places ON place_id = area_id WHERE name = 'England'))
-- code/q-recursion-continents.dl: the places within more than one continent
UNION ALL SELECT 'multicontinent', (SELECT count(*) FROM (
    SELECT DISTINCT w.place_id FROM within AS w
    WHERE  w.area_id NOT IN (SELECT place_id FROM located_in)
    GROUP BY w.place_id HAVING count(DISTINCT w.area_id) > 1));
