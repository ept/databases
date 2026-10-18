-- name: Counts over the JSON documents quoted in the notes, slides and solutions
-- format: macros
-- prefix: json
-- thousands: n
SELECT 'movies' AS name, count(*) AS n FROM movies
UNION ALL SELECT 'people', count(*) FROM people
-- For s:json-types: the same condition with and without an explicit cast. Comparing a
-- JSON value with the integer 8 casts the JSON to INTEGER, which rounds every rating
-- from 7.5 to 8.4 to 8, so the uncast count is far too high. If a refresh ever makes the
-- two equal, the slide's point has gone.
UNION ALL SELECT 'ratingwrong', count(*) FROM movies WHERE (movie->'rating') >= 8
UNION ALL SELECT 'ratingright', count(*) FROM movies WHERE (movie->>'rating')::DOUBLE >= 8
-- For s:json-lists; the conditions are those of code/json-list-*.sql.
UNION ALL SELECT 'war', count(*) FROM movies
    WHERE list_contains(movie->>'$.genres[*]', 'War')
UNION ALL SELECT 'romcom', count(*) FROM movies
    WHERE list_has_all(movie->>'$.genres[*]', ['Romance', 'Comedy'])
UNION ALL SELECT 'spielberg', count(*) FROM movies
    WHERE list_contains(movie->>'$.directors[*].name', 'Steven Spielberg')
-- For s:json-missing; the conditions are those of code/json-exists.sql.
UNION ALL SELECT 'composers', count(*) FROM people
    WHERE json_exists(person, '$.composed_for')
UNION ALL SELECT 'neveracted', count(*) FROM people
    WHERE NOT json_exists(person, '$.acted_in')
-- For s:same-fact-twice: how many documents carry a copy of Chaplin's name, and of
-- The Kid's title. $.*[*] is every element of every array at the top level of the
-- document, i.e. every credit. A person may hold several credits on one movie, so the
-- number of copies (mentions) exceeds the number of documents.
UNION ALL SELECT 'chaplindocs', count(*) FROM movies
    WHERE list_contains(movie->>'$.*[*].person_id', 'nm0000122')
UNION ALL SELECT 'chaplinmentions', count(*)
    FROM movies, unnest(movie->>'$.*[*].person_id') AS t(id) WHERE id = 'nm0000122'
UNION ALL SELECT 'kiddocs', count(*) FROM people
    WHERE list_contains(person->>'$.*[*].movie_id', 'tt0012349')
-- For the prose after s:same-fact-twice: copies that disagree with the original. Both
-- are 0 in the generated data, and the prose says so; if either ever becomes nonzero,
-- the prose needs rewriting (and has a better example).
UNION ALL SELECT 'namemismatches', count(*)
    FROM movies, unnest(movie->'$.*[*]') AS t(c), people
    WHERE person_id = (c->>'person_id') AND (c->>'name') <> (person->>'name')
UNION ALL SELECT 'titlemismatches', count(*)
    FROM people, unnest(person->'$.*[*]') AS t(c), movies
    WHERE movie_id = (c->>'movie_id') AND (c->>'title') <> (movie->>'title')
-- For the prose after s:json-person: the job key is present in some elements of a
-- directed array and absent from others.
UNION ALL SELECT 'directedjob', count(*)
    FROM people, unnest(person->'$.directed[*]') AS t(c) WHERE json_exists(c, '$.job')
UNION ALL SELECT 'directednojob', count(*)
    FROM people, unnest(person->'$.directed[*]') AS t(c) WHERE NOT json_exists(c, '$.job')
-- For s:json-missing: the documents contain no JSON null anywhere; an unknown value is
-- an absent key. The prose says so, and must change if this ever becomes nonzero.
UNION ALL SELECT 'nulls', (SELECT count(*) FROM movies, json_tree(movie) AS t
                           WHERE t.type = 'NULL')
                        + (SELECT count(*) FROM people, json_tree(person) AS t
                           WHERE t.type = 'NULL')
-- For the solution to q:json-queries: movies one of whose directors also acted in them,
-- by the condition of code/q-json-actor-director.sql.
UNION ALL SELECT 'actordirector', count(*) FROM movies
    WHERE list_has_any(movie->>'$.directors[*].person_id', movie->>'$.actors[*].person_id')
-- For the solution to q:json-queries: the movie documents that would have to change if
-- Lana Wachowski's name changed, found by her ID. The solution says these are the movies
-- its second query returns, so the two must agree.
UNION ALL SELECT 'lanadocs', count(*) FROM movies
    WHERE list_contains(movie->>'$.*[*].person_id', 'nm0905154');
