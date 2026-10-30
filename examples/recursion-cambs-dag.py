#!/usr/bin/env python3
r"""Lay out the places within Cambridgeshire and their movies as a graph, for TikZ.

Usage:  python3 examples/recursion-cambs-dag.py moviedb-2025/movies-locations.duckdb examples/recursion-cambs-dag.tex

Writes a LaTeX fragment of macro calls that the slides s:cambs-dag-down and
s:cambs-dag-right define (see setup.tex), each in its own way, to draw the places within
Cambridgeshire and the movies filmed at them as vertices, and the located_in and filmed_at
facts between them as edges:

    \dagplace{node}{x}{y}{x'}{y'}{narrow}{wide}   a place
    \dagmovie{node}{x}{y}{x'}{y'}{narrow}{wide}   a movie
    \daglocated{from}{to}                         located_in(from, to)
    \dagfilmed{from}{to}                          filmed_at(from, to): movie to place

(x, y) is the position in cm on s:cambs-dag-down, where the places go from Cambridgeshire
at the top down to the places within it, and the movies are in a column on the right; and
(x', y') on s:cambs-dag-right, where the places go from Cambridgeshire on the left to the
right, each level as far from the previous one as their widest vertices need, and the
movies are in two staggered rows underneath. A place is the centre of its
vertex, and a movie the west (down) or north (right) side of its vertex.

The places are arranged in levels: level 0 is Cambridgeshire, and level n contains the
places n located_in steps below it, along the longest path. Within a level, they are laid
out as a tidy tree: going depth-first from Cambridgeshire, in alphabetical order, each
subtree is placed as close to the previous ones as it can be without any two vertices on
the same level overlapping, and each place sits midway between its first and last
children. A place with several parents is laid out under the first, and then moved midway
between its parents.

Each movie is placed half a level beyond the mean level of the places it was filmed at, so
that its edges tend to run between the levels rather than along them, and then the movies
are pushed apart, in order of that position, until their vertices no longer overlap, and
moved back as a group as far as needed to stay within the extent of the places.

The sizes of the vertices are estimated from the number of characters and lines of their
labels, in \tiny type; the constants below must match the styles on the slides. Each name
is given twice, wrapped with \\ into lines of at most NARROW characters (or a single longer
word), and at most WIDE characters for a place or MEDIUM for a movie; each slide uses the
version that suits its orientation. Wrapping here, at spaces, rather than with a text width
in TikZ, means that no word is hyphenated.

Like examples/render.py, this only lays out what the database contains. It runs against
the version of the database with the filming locations (see locations/README.md).
"""

import collections
import os
import sys
import textwrap

import duckdb

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from render import latex_escape  # noqa: E402

ROOT = 'Cambridgeshire'
NARROW, MEDIUM, WIDE = 12, 14, 20
CHAR = 0.105        # cm, the mean width of a character in \tiny sans-serif
LINE = 0.25         # cm, the height of a line of \tiny
PAD = 0.16          # cm, inner sep and border of a vertex, on both sides together
GAP = 0.12          # cm, the least space between two vertices
LEVEL_DOWN = 1.45   # cm between levels, top to bottom
COLUMN_GAP = 0.7    # cm between the widest vertices of two levels, left to right
ROWS_RIGHT = 0.95   # cm between the two rows of movies, left to right


def lines(text, width):
    return textwrap.wrap(text, width, break_long_words=False, break_on_hyphens=False)


def label(text, width):
    return r'\\'.join(latex_escape(line) for line in lines(text, width))


def width(text, wrap):
    return max(len(line) for line in lines(text, wrap)) * CHAR + PAD


def height(text, wrap):
    return len(lines(text, wrap)) * LINE + PAD


def mean(values):
    return sum(values) / len(values)


def tidy(root, children, level, size):
    """Positions across the levels, for a tidy tree layout with the given vertex sizes."""
    placed = set()

    def subtree(place):
        # Returns the offsets of the places in the subtree relative to `place`, and its
        # contour: for each level, the extent of the subtree's vertices on that level.
        placed.add(place)
        offsets, contour, roots = {}, {}, []
        for child in sorted(children[place], key=lambda c: c[1]):
            if child[0] in placed:
                continue
            child_offsets, child_contour = subtree(child[0])
            shift = max((contour[l][1] + GAP - child_contour[l][0]
                         for l in child_contour if l in contour), default=0)
            for p, x in child_offsets.items():
                offsets[p] = x + shift
            for l, (lo, hi) in child_contour.items():
                if l in contour:
                    contour[l] = (min(contour[l][0], lo + shift), max(contour[l][1], hi + shift))
                else:
                    contour[l] = (lo + shift, hi + shift)
            roots.append(offsets[child[0]])
        middle = (roots[0] + roots[-1]) / 2 if roots else 0
        offsets = {p: x - middle for p, x in offsets.items()}
        contour = {l: (lo - middle, hi - middle) for l, (lo, hi) in contour.items()}
        offsets[place] = 0
        contour[level[place]] = (-size(place) / 2, size(place) / 2)
        return offsets, contour

    offsets, _ = subtree(root)
    lowest = min(x - size(p) / 2 for p, x in offsets.items())
    return {p: x - lowest for p, x in offsets.items()}


def spread(order, target, needed, lowest, highest):
    """Positions as close to the targets as possible, in the given order, with at least
    needed(i, j) between the i-th and j-th; then moved back within [lowest, highest]."""
    position = []
    for i, item in enumerate(order):
        x = target[item]
        for j in range(i):
            x = max(x, position[j] + needed(j, i))
        position.append(x)
    excess = position[-1] - highest
    if excess > 0:
        position = [x - min(excess, position[0] - lowest) for x in position]
    return dict(zip(order, position))


def main():
    if len(sys.argv) != 3:
        sys.exit(__doc__.strip().splitlines()[2].strip())
    database, output = sys.argv[1], sys.argv[2]
    connection = duckdb.connect(database, read_only=True)
    names = dict(connection.execute('SELECT place_id, name FROM places').fetchall())
    roots = [p for p, n in names.items() if n == ROOT]
    if len(roots) != 1:
        sys.exit('%s: expected one place called %s, found %d' % (database, ROOT, len(roots)))
    root = roots[0]
    all_children = collections.defaultdict(list)
    for place, parent in connection.execute('SELECT place_id, parent_id FROM located_in').fetchall():
        all_children[parent].append(place)

    # The places within the root, and the links between them
    places, todo = {root}, [root]
    while todo:
        for child in all_children[todo.pop()]:
            if child not in places:
                places.add(child)
                todo.append(child)
    links = sorted((c, p) for p in places for c in all_children[p])
    parents = collections.defaultdict(list)
    children = collections.defaultdict(list)
    for child, parent in links:
        parents[child].append(parent)
        children[parent].append((child, names[child]))

    level = {}

    def find_level(place):
        if place not in level:
            level[place] = max((find_level(p) + 1 for p in parents[place]), default=0)
        return level[place]
    for place in places:
        find_level(place)

    across_down = tidy(root, children, level, lambda p: width(names[p], NARROW))
    across_right = tidy(root, children, level, lambda p: height(names[p], WIDE))
    for across in (across_down, across_right):
        for place in sorted(places, key=lambda p: level[p]):
            if len(parents[place]) > 1:
                across[place] = mean([across[p] for p in parents[place]])
    deepest = max(level.values())
    # Left to right, each level is as far from the previous one as its widest vertex needs
    widest = [max(width(names[p], WIDE) for p in places if level[p] == l) for l in range(deepest + 1)]
    columns = [0]
    for l in range(1, deepest + 1):
        columns.append(columns[-1] + (widest[l - 1] + widest[l]) / 2 + COLUMN_GAP)

    def column(t):  # the x of a fractional level, between (or beyond) the columns
        l = min(int(t), deepest - 1)
        return columns[l] + (t - l) * (columns[l + 1] - columns[l])
    down = {p: (across_down[p], -level[p] * LEVEL_DOWN) for p in places}
    right = {p: (columns[level[p]], -across_right[p]) for p in places}

    # The movies, and where they were filmed
    filmed = connection.execute("""
        SELECT f.movie_id, m.title, f.place_id
        FROM   filmed_at AS f JOIN movies AS m ON m.movie_id = f.movie_id
        ORDER BY f.movie_id, f.place_id""").fetchall()
    connection.close()
    filmed = [row for row in filmed if row[2] in places]
    titles = {movie: title for movie, title, _ in filmed}
    at = collections.defaultdict(list)
    for movie, _, place in filmed:
        at[movie].append(place)
    target = {m: mean([level[p] for p in at[m]]) + 0.5 for m in titles}
    movies = sorted(titles, key=lambda m: (target[m], mean([across_down[p] for p in at[m]]), titles[m]))

    # Down: a column to the right of the places, top edges at the positions (downwards)
    heights = [height(titles[m], MEDIUM) for m in movies]
    tops = spread(movies, {m: target[m] * LEVEL_DOWN - heights[i] / 2 for i, m in enumerate(movies)},
                  lambda j, i: heights[j] + GAP / 2 if j == i - 1 else 0,
                  0, (deepest + 0.5) * LEVEL_DOWN)
    left = max(x + width(names[p], NARROW) / 2 for p, (x, _) in down.items()) + 0.3
    movie_down = {m: (left, -tops[m] - heights[i] / 2) for i, m in enumerate(movies)}

    # Right: two rows underneath the places, alternately, so that a movie only needs room
    # beside the ones in its own row
    widths = [width(titles[m], NARROW) for m in movies]
    lowest_place = min(y - height(names[p], WIDE) / 2 for p, (_, y) in right.items())
    centres = spread(movies, {m: column(target[m]) for m in movies},
                     lambda j, i: ((widths[j] + widths[i]) / 2 + GAP if j == i - 2 else
                                   0.3 if j == i - 1 else 0),
                     min(x - width(names[p], WIDE) / 2 for p, (x, _) in right.items()) + widths[0] / 2,
                     max(x + width(names[p], WIDE) / 2 for p, (x, _) in right.items()) - widths[-1] / 2)
    movie_right = {m: (centres[m], lowest_place - 0.6 - (i % 2) * ROWS_RIGHT) for i, m in enumerate(movies)}

    out_lines = []
    for place in sorted(places, key=lambda p: (level[p], across_down[p])):
        out_lines.append(r'\dagplace{%s}{%.2f}{%.2f}{%.2f}{%.2f}{%s}{%s}' % (
            place, *down[place], *right[place], label(names[place], NARROW), label(names[place], WIDE)))
    for movie in movies:
        out_lines.append(r'\dagmovie{%s}{%.2f}{%.2f}{%.2f}{%.2f}{%s}{%s}' % (
            movie, *movie_down[movie], *movie_right[movie],
            label(titles[movie], NARROW), label(titles[movie], MEDIUM)))
    for child, parent in links:
        out_lines.append(r'\daglocated{%s}{%s}' % (child, parent))
    for movie, _, place in filmed:
        out_lines.append(r'\dagfilmed{%s}{%s}' % (movie, place))
    with open(output, 'w', encoding='utf-8') as out:
        out.write('% The places within Cambridgeshire and their movies, laid out as a graph\n')
        out.write('% Generated by examples/recursion-cambs-dag.py -- do not edit.\n')
        out.write('% Regenerate with: make examples\n')
        out.write('\n'.join(out_lines) + '\n')
    print('%s -> %s (%d places, %d movies)' % (database, output, len(places), len(movies)))


if __name__ == '__main__':
    main()
