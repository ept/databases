# Filming locations

The Datalog version of the movies database (`make database-datalog`, the download zip and
the playground) has three relations that the other versions don't have yet:

    places(place_id, name)            every place, with its English name
    located_in(place_id, parent_id)   the place is directly within the parent place
    filmed_at(movie_id, place_id)     the movie was filmed at the place

The places form a directed acyclic graph whose roots are the seven continents. Most places
have one parent, for example Cambridge < Cambridgeshire < East of England < England <
United Kingdom < Europe, but some have several: Monument Valley is in both Utah and
Arizona, and Turkey is in both Europe and Asia. They are there to give recursive queries
something natural to work on, such as "all the movies filmed in England".

## Source

The data comes from [Wikidata](https://www.wikidata.org/), whose structured data is
released under [CC0](https://creativecommons.org/publicdomain/zero/1.0/) (public domain),
so it can be redistributed freely; crediting Wikidata is courteous, not required. The
properties used are:

* [P915](https://www.wikidata.org/wiki/Property:P915) filming location, looking up each
  movie by its IMDb ID ([P345](https://www.wikidata.org/wiki/Property:P345)),
* [P131](https://www.wikidata.org/wiki/Property:P131) located in the administrative
  territorial entity,
* [P17](https://www.wikidata.org/wiki/Property:P17) country,
* [P30](https://www.wikidata.org/wiki/Property:P30) continent,
* [P576](https://www.wikidata.org/wiki/Property:P576) dissolved, abolished or demolished,

and the English labels (falling back to the `mul` label, which Wikidata uses for names
that are the same in many languages).

## Files

* `fetch.py` queries the Wikidata SPARQL endpoint and writes the raw snapshot,
  `wikidata.json`. Its date is in the `fetched` field.
* `clean.py` turns the snapshot into `places.facts`, `located_in.facts` and
  `filmed_at.facts`. The comment at its top describes the cleaning step by step: it picks
  the current values of the properties, makes the continents the only roots, removes
  redundant links, merges places with their parents when they have the same name (the city
  and the district of Cambridge), and skips places without a name.
* `examples/souffle-export.py` copies the three fact files into the Datalog database,
  alongside the relations it exports from the relational database.

All of these are committed, so building the database needs no network access, and the data
only changes when someone refreshes it deliberately.

## Refreshing the data

For example when the course moves to a new year's database (which may contain different
movies), or to pick up corrections made on Wikidata since:

    uv run locations/fetch.py moviedb-2027/movies.duckdb locations/wikidata.json   # a few minutes
    python3 locations/clean.py locations/wikidata.json locations
    git diff --stat locations/
    make database-datalog database-datalog-zip playground-datalog check-datalog \
         MOVIEDB=moviedb-2027/movies.duckdb

`fetch.py` sends a few hundred queries, pausing between them and retrying with a backoff
if Wikidata times out or rate-limits it. Its User-Agent identifies the course, as
[Wikimedia's policy](https://meta.wikimedia.org/wiki/User-Agent_policy) asks.

`clean.py` prints some statistics; compare them with the previous run (in October 2026:
2804 places, 3003 `located_in` links, 4647 `filmed_at` facts about 1775 movies, 127 places
with more than one parent), and look through the list of filming locations it had to drop.
Since anyone can edit Wikidata, a refresh can also bring in vandalism or odd modelling
choices; spot-check a few chains of `located_in`, and keep any example used on the slides
working (the slides draw their numbers from `examples/*.dl`, so `make refresh` and
`git diff examples/` show what changed).

If the movies in the database change without a refresh, `souffle-export.py` leaves out
the filming locations of movies that are no longer there, and says how many.
