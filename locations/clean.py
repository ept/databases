#!/usr/bin/env python3
"""Turn the raw Wikidata snapshot into fact files for the filming locations.

Usage:  python3 locations/clean.py locations/wikidata.json locations

Reads the snapshot written by locations/fetch.py and writes three tab-separated fact files
into the output directory:

    places.facts      place_id, name     every place, with its English name
    located_in.facts  place_id, parent   the place is directly within the parent place
    filmed_at.facts   movie_id, place_id the movie was filmed at the place

The places form a directed acyclic graph whose roots are the seven continents. Most places
have one parent, but some have several (a bridge between two boroughs, a city spanning
four counties, a country on two continents). The data is cleaned automatically, as follows:

1.  For each place and property, take the statements that Wikidata itself would return as
    the property's current value: the preferred ones if there are any, and otherwise the
    normal ones (fetch.py has already dropped deprecated statements and those with an end
    time). Ignore parents that have been dissolved, and parents that are the place itself.

2.  Use the continents as roots, and nothing else. Some continent statements name
    something like a continent, which is mapped to the continent (Insular Oceania and the
    Australian continent to Oceania, Central America to North America); others (the
    Americas, Eurasia) are ignored.

3.  The parents of a place are its P131 parents ("located in the administrative territorial
    entity") from which a continent can be reached. If there are none, they are its
    countries (P17) from which a continent can be reached, and if there are none of those
    either, its continents (P30). A place from which no continent can be reached is
    dropped, along with its filming locations; the script prints them. Choosing parents
    only among places that have already been found to reach a continent also guarantees
    that the result has no cycles.

4.  Remove the redundant links: if a place is in A, and also in B which is in A, the direct
    link to A says nothing new (this is the transitive reduction of the graph).

5.  Merge a place into its parent when both have the same name, such as the city of
    Cambridge and the district of Cambridge. The merged place keeps the ID of whichever of
    the two is used more often as a filming location (the child, if neither is), and the
    parents of both.

6.  Skip places without an English name: their children are linked to their parents
    instead. Filming locations without an English name are dropped.

Finally, the script prints a few statistics, which are worth comparing after a refresh.
"""

import collections
import json
import os
import sys

CONTINENTS = {
    'Q15': 'Africa', 'Q51': 'Antarctica', 'Q48': 'Asia', 'Q46': 'Europe',
    'Q49': 'North America', 'Q55643': 'Oceania', 'Q18': 'South America',
}
CONTINENT_ALIASES = {
    'Q538': 'Q55643',    # Insular Oceania
    'Q3960': 'Q55643',   # Australian continent
    'Q27611': 'Q49',     # Central America
}
PROPERTIES = ['P131', 'P17', 'P30']  # in order of preference


def candidate_parents(snapshot):
    """Step 1 and 2: {place: {property: [parents]}}, the current value of each property."""
    dissolved = set(snapshot['dissolved'])
    by_rank = collections.defaultdict(lambda: collections.defaultdict(set))
    for place, prop, parent, rank in snapshot['statements']:
        if prop == 'P30':
            parent = CONTINENT_ALIASES.get(parent, parent)
            if parent not in CONTINENTS:
                continue
        by_rank[(place, prop)][rank].add(parent)
    candidates = collections.defaultdict(dict)
    for (place, prop), ranks in by_rank.items():
        if place in CONTINENTS:
            continue  # the roots
        chosen = ranks.get('preferred') or ranks['normal']
        chosen = sorted(p for p in chosen if p != place and p not in dissolved)
        if chosen:
            candidates[place][prop] = chosen
    return candidates


def choose_parents(candidates, places):
    """Step 3: {place: [parents]}, for every place from which a continent can be reached."""
    parents = {c: [] for c in CONTINENTS}
    unreachable = set()

    def visit(place, stack):
        if place in parents:
            return True
        if place in unreachable or place in stack:
            return False
        stack.add(place)
        for prop in PROPERTIES:
            found = [p for p in candidates[place].get(prop, []) if visit(p, stack)]
            if found:
                parents[place] = found
                break
        stack.discard(place)
        if place not in parents:
            # A place on the stack counts as unreachable from here, but may still reach a
            # continent along another path; so only remember failures found outside a cycle
            if not stack:
                unreachable.add(place)
            return False
        return True

    for place in sorted(places):
        visit(place, set())
    return parents


def ancestors(parents, place, memo):
    if place not in memo:
        result = set()
        for p in parents[place]:
            result.add(p)
            result |= ancestors(parents, p, memo)
        memo[place] = result
    return memo[place]


def transitive_reduction(parents):
    """Step 4."""
    memo = {}
    reduced = {}
    for place, ps in parents.items():
        reduced[place] = sorted(p for p in ps if not any(p in ancestors(parents, q, memo) for q in ps if q != p))
    return reduced


def merge_same_names(parents, labels, uses):
    """Step 5: returns (parents, {merged place: the place it was merged into})."""
    merged = {}
    while True:
        pair = next(((c, p) for c in sorted(parents) for p in parents[c]
                     if labels.get(c) is not None and labels.get(c) == labels.get(p)), None)
        if pair is None:
            return parents, merged
        child, parent = pair
        keep, drop = (parent, child) if uses[parent] > uses[child] else (child, parent)
        new = dict(parents)
        new[keep] = sorted((set(parents[child]) | set(parents[parent])) - {child, parent})
        del new[drop]
        for place, ps in new.items():
            if drop in ps:
                new[place] = sorted({keep if p == drop else p for p in ps} - {place})
        for old, into in merged.items():
            if into == drop:
                merged[old] = keep
        merged[drop] = keep
        parents = transitive_reduction(new)


def skip_unnamed(parents, labels):
    """Step 6, for the places other than filming locations."""
    def named_parents(place, seen=()):
        result = set()
        for p in parents[place]:
            if p in labels:
                result.add(p)
            elif p not in seen:
                result |= named_parents(p, seen + (p,))
        return result
    return transitive_reduction({place: sorted(named_parents(place)) for place in parents if place in labels})


def check_acyclic(parents):
    state = {}

    def visit(place):
        if state.get(place) == 'done':
            return
        if state.get(place) == 'active':
            sys.exit('cycle through %s' % place)
        state[place] = 'active'
        for p in parents[place]:
            visit(p)
        state[place] = 'done'

    for place in parents:
        visit(place)


def write_facts(path, rows):
    with open(path, 'w', encoding='utf-8') as out:
        for row in sorted(rows):
            for value in row:
                if any(ch in value for ch in '\t\n\r\\'):
                    sys.exit('cannot write %r to a fact file: it contains a tab, newline or backslash' % value)
            out.write('\t'.join(row) + '\n')


def main():
    if len(sys.argv) != 3:
        sys.exit(__doc__.strip().splitlines()[2].strip())
    snapshot_path, outdir = sys.argv[1], sys.argv[2]
    with open(snapshot_path, encoding='utf-8') as f:
        snapshot = json.load(f)
    labels = dict(snapshot['labels'])
    labels.update(CONTINENTS)
    filmed_at = [tuple(row) for row in snapshot['filmed_at']]
    uses = collections.Counter(place for _, place in filmed_at)

    candidates = candidate_parents(snapshot)
    parents = choose_parents(candidates, {place for _, place in filmed_at})
    parents = transitive_reduction(parents)
    parents, merged = merge_same_names(parents, labels, uses)
    parents = skip_unnamed(parents, labels)
    check_acyclic(parents)

    filmed_at = {(movie, merged.get(place, place)) for movie, place in filmed_at}
    dropped = sorted({place for _, place in filmed_at if place not in parents})
    filmed_at = {(movie, place) for movie, place in filmed_at if place in parents}

    # Keep only the filming locations and the places that contain them
    keep, todo = set(), {place for _, place in filmed_at}
    while todo:
        place = todo.pop()
        keep.add(place)
        todo |= set(parents[place]) - keep

    os.makedirs(outdir, exist_ok=True)
    write_facts(os.path.join(outdir, 'places.facts'), [(p, labels[p]) for p in keep])
    write_facts(os.path.join(outdir, 'located_in.facts'), [(p, q) for p in keep for q in parents[p]])
    write_facts(os.path.join(outdir, 'filmed_at.facts'), filmed_at)

    print('snapshot fetched on %s' % snapshot['fetched'])
    print('%d places, %d located_in links, %d filmed_at facts about %d movies' % (
        len(keep), sum(len(parents[p]) for p in keep), len(filmed_at), len({m for m, _ in filmed_at})))
    print('%d places with more than one parent; %d merged with a parent of the same name' % (
        sum(len(parents[p]) > 1 for p in keep), len(merged)))
    depth = {}

    def longest(place):
        if place not in depth:
            depth[place] = 1 + max((longest(p) for p in parents[place]), default=0)
        return depth[place]
    print('longest path from a filming location up to its continent (places on it): %s' % ', '.join(
        '%d: %d' % kv for kv in sorted(collections.Counter(longest(p) for p in {p for _, p in filmed_at}).items())))
    if dropped:
        print('dropped %d filming locations that lead to no continent or have no English name: %s' % (
            len(dropped), ', '.join('%s (%s)' % (p, labels.get(p, 'no name')) for p in dropped)))


if __name__ == '__main__':
    main()
