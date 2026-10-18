#!/usr/bin/env python3
"""Render the result of a SQL query as a LaTeX fragment.

Usage:  python3 examples/render.py <database.duckdb> <examples/query.sql> [-o out.tex]
        python3 examples/render.py <database.tvdb> <examples/query.cypher> [-o out.tex]

Runs the query in <query.sql> against <database.duckdb> and writes the formatted
result to <examples/query.tex> (or the path given with -o), ready to be pulled into
databases.tex with \\input.

A query file ending in .cypher is a Cypher query instead, run against a Traverse graph
database by examples/traverse-query.mjs under Node. Its directives are the same, written
as `// key: value` comments, and its result is formatted in the same way.

Only data that depends on the *contents* of the example database belongs here.
Anything that follows from the schema alone (the schema diagram, the CREATE TABLE
listings) is hard-coded in databases.tex, because the schema does not change from
year to year.

Formatting is controlled by `-- key: value` directives in comments at the top of the
.sql file:

  name        Human-readable description, copied into the output as a comment.
  format      table   a complete `tabular` environment (default for multi-cell results)
              scalar  just the value, for use inline in a sentence (default for 1x1)
              list    inline list of one row per item, joined with `separator`
              macros  \\newcommand definitions from a (name, value) result
              json    one JSON value (one row, one column), pretty-printed to <query>.json
                      beside the .tex, which holds an \\inputminted of it. The listing
                      takes the font size of the group it is \\input in.
  align      One letter (l/r/c) per column, e.g. `llrlr`.
              Default: r for numbers, l for everything else.
  headers     none (default) | auto (use the query's column names) | a comma-separated list
  rules       box (default: vertical rules + \\hline top and bottom) | plain (no verticals)
  tt          Comma-separated column names to wrap in \\texttt{}.
  thousands   Comma-separated column names to group in thousands (1234 -> 1,234).
              Off by default, so that years are not mangled into "1,921".
  round       Comma-separated col=digits pairs, e.g. `avg=1`.
  null        LaTeX for a NULL value. Default: \\textit{null}.
  maxrows     Truncate to this many rows, adding a row of dots.
  conjunction Word before the last item of a `list`, e.g. `or`.
  separator   Punctuation between the items of a `list`; a space is added after it.
              Default `,`.
  template    For a `list`, how to render each row, with `{column}` standing for that
              column's value, e.g. ```{title}'' is {genres}``. Values are escaped as
              usual, so the LaTeX lives here in the directive rather than in the query.
  prefix      Macro-name prefix for `format: macros`.
  mark        Comma-separated col=prefix pairs, e.g. `movie_id=mv`. Wraps that column's
              cells in \tikzmarknode so a later [remember picture,overlay] tikzpicture can
              draw on them: <prefix>0 is the header cell, <prefix>1 the first data row, and
              so on. Used for the circles and braces on the key slides. Prefixes must be
              unique across the whole document, since the names are global.
  allow-empty yes, to permit a query that returns no rows (normally an error).
  maxitems    For `json`, comma-separated key=n pairs: an array under that key keeps only
              its first n elements, followed by a comment saying how many were left out.
              Applies at any depth, so `roles=1` abridges every actor's roles.
  omit        For `json`, comma-separated keys to leave out of every object, with a
              comment at the end of the object naming them.
  width       For `json`, the line length within which an object or array is kept on one
              line rather than broken up, one member per line. Default 70: a slide is
              307pt wide, and a \\scriptsize typewriter character 4.25pt, so 72 fit.

A value of SQL type LIST (such as the result of a JSONPath wildcard `$.genres[*]`) is
shown as `[a, b, c]`, as the DuckDB shell shows it.
"""

import argparse
import json
import os
import re
import subprocess
import sys
from decimal import Decimal

import duckdb

SPECIALS = {'\\': r'\textbackslash{}', '{': r'\{', '}': r'\}', '$': r'\$',
            '&': r'\&', '#': r'\#', '_': r'\_', '%': r'\%',
            '^': r'\^{}', '~': r'\~{}'}


def latex_escape(text):
    return ''.join(SPECIALS.get(ch, ch) for ch in text)


def parse_directives(sql):
    """Read `-- key: value` lines (or `// key: value` in Cypher) from the top of the file."""
    directives = {}
    for line in sql.splitlines():
        stripped = line.strip()
        if not stripped:
            continue
        if not stripped.startswith(('--', '//')):
            break
        match = re.match(r'(?:--|//)\s*([a-z-]+)\s*:\s*(.*)$', stripped)
        if match:
            directives[match.group(1)] = match.group(2).strip()
    return directives


def split_list(value):
    return [item.strip() for item in value.split(',') if item.strip()]


def split_pairs(value):
    pairs = {}
    for item in split_list(value):
        key, _, val = item.partition('=')
        pairs[key.strip()] = val.strip()
    return pairs


def format_cell(value, column, directives, rounding, mark=None):
    text = format_value(value, column, directives, rounding)
    if mark:
        text = r'\tikzmarknode{%s}{%s}' % (mark, text)
    return text


def format_value(value, column, directives, rounding):
    if value is None:
        return directives.get('null', r'\textit{null}')
    if isinstance(value, bool):
        # Python prints True/False; SQL clients print true/false, and these fragments are
        # meant to look like what a student sees in the shell. Must come before the int
        # tests below, since bool is a subclass of int.
        return 'true' if value else 'false'
    if isinstance(value, Decimal):
        # DuckDB reads SQL NUMERIC as DECIMAL(18,3), which would print a rating of 8.2 as
        # 8.200. Go through float so the text is the shortest form of the same number.
        value = float(value)
    if isinstance(value, list):
        # A SQL LIST, e.g. from data->>'$.genres[*]'. Python would print ['Comedy', ...]
        # with quotes; the DuckDB shell prints [Comedy, ...], which is what students see.
        text = '[%s]' % ', '.join('NULL' if v is None else str(v) for v in value)
        text = latex_escape(text)
        if column in split_list(directives.get('tt', '')):
            text = r'\texttt{%s}' % text
        return text
    if column in rounding and isinstance(value, float):
        text = '{:.{}f}'.format(value, rounding[column])
    elif column in split_list(directives.get('thousands', '')) and isinstance(value, int):
        text = '{:,}'.format(value)
    else:
        text = str(value)
    text = latex_escape(text)
    if column in split_list(directives.get('tt', '')):
        text = r'\texttt{%s}' % text
    return text


def infer_align(rows, columns, directives):
    if 'align' in directives:
        return list(directives['align'].replace(' ', ''))
    align = []
    for index in range(len(columns)):
        values = [row[index] for row in rows if row[index] is not None]
        # `not isinstance(v, bool)` matters: bool is a subclass of int, so without it a
        # column of true/false would be right-aligned like a number.
        numeric = values and all(isinstance(v, (int, float, Decimal))
                                 and not isinstance(v, bool) for v in values)
        align.append('r' if numeric else 'l')
    return align


def render_table(rows, columns, directives, rounding):
    align = infer_align(rows, columns, directives)
    if len(align) != len(columns):
        sys.exit('align has %d entries but the query returns %d columns'
                 % (len(align), len(columns)))

    boxed = directives.get('rules', 'box') == 'box'
    spec = '|' + '|'.join(align) + '|' if boxed else '|'.join(align)

    header = directives.get('headers', 'none')
    if header == 'auto':
        labels = list(columns)
    elif header == 'none':
        labels = None
    else:
        labels = split_list(header)
        if len(labels) != len(columns):
            sys.exit('headers has %d entries but the query returns %d columns'
                     % (len(labels), len(columns)))

    maxrows = int(directives['maxrows']) if 'maxrows' in directives else None
    truncated = maxrows is not None and len(rows) > maxrows
    shown = rows[:maxrows] if truncated else rows

    lines = [r'\begin{tabular}{%s}\hline' % spec]
    marks = split_pairs(directives.get('mark', ''))

    def mark_name(index, row_number):
        prefix = marks.get(columns[index])
        return '%s%d' % (prefix, row_number) if prefix else None

    if labels is not None:
        cells = []
        for i, label in enumerate(labels):
            cell = r'\textbf{%s}' % latex_escape(label)
            name = mark_name(i, 0)
            if name:
                cell = r'\tikzmarknode{%s}{%s}' % (name, cell)
            cells.append(cell)
        lines.append('    ' + ' & '.join(cells) + r' \\\hline')
    body = []
    for number, row in enumerate(shown, start=1):
        body.append('    ' + ' & '.join(
            format_cell(row[i], columns[i], directives, rounding, mark_name(i, number))
            for i in range(len(columns))))
    if truncated:
        body.append('    ' + ' & '.join([r'$\vdots$'] * len(columns)))
    lines.append((r' \\' + '\n').join(body) + r' \\\hline')
    lines.append(r'\end{tabular}')
    return '\n'.join(lines)


def render_scalar(rows, columns, directives, rounding):
    if len(rows) != 1 or len(columns) != 1:
        sys.exit('format: scalar needs a query returning exactly one row and one column, '
                 'but got %d rows and %d columns' % (len(rows), len(columns)))
    return format_cell(rows[0][0], columns[0], directives, rounding)


def render_list(rows, columns, directives, rounding):
    template = directives.get('template')
    if template:
        items = []
        for row in rows:
            text = template
            for index, column in enumerate(columns):
                text = text.replace('{%s}' % column,
                                    format_cell(row[index], column, directives, rounding))
            leftover = re.findall(r'\{(\w+)\}', text)
            if leftover:
                sys.exit('template names columns the query does not return: %s'
                         % ', '.join(sorted(set(leftover))))
            items.append(text)
    else:
        if len(columns) != 1:
            sys.exit('format: list needs a query returning exactly one column (or a '
                     'template), got %d' % len(columns))
        items = [format_cell(row[0], columns[0], directives, rounding) for row in rows]
    separator = directives.get('separator', ',') + ' '
    conjunction = directives.get('conjunction')
    if conjunction and len(items) > 1:
        return separator.join(items[:-1]) + '%s%s %s' % (separator, conjunction, items[-1])
    return separator.join(items)


def render_macros(rows, columns, directives, rounding):
    if len(columns) != 2:
        sys.exit('format: macros needs a query returning two columns (name, value), got %d'
                 % len(columns))
    prefix = directives.get('prefix', '')
    lines = []
    for name, _ in rows:
        if not re.fullmatch(r'[A-Za-z]+', str(name)):
            sys.exit('macro name %r must consist of letters only, so that it forms a '
                     'valid LaTeX command name' % (name,))
    for row in rows:
        value = format_cell(row[1], columns[1], directives, rounding)
        lines.append(r'\newcommand{\%s%s}{%s}' % (prefix, row[0], value))
    return '\n'.join(lines)


def pretty_json(value, abridge, width, indent=0, key=None, prefix=0):
    """Lay out a JSON value for a slide: on one line if it fits within `width`, otherwise
    one member per line. json.dumps(indent=2) breaks every array onto separate lines, so
    a list of three genres would take five lines; this keeps short things short.

    `abridge` holds the maxitems and omit directives. `key` is the name the value is
    stored under, which is what those directives match on; `prefix` is the number of
    characters that precede the value on its line (the key, its quotes and the colon)."""
    maxitems, omit = abridge
    comments = []
    if isinstance(value, list) and key in maxitems and len(value) > maxitems[key]:
        omitted = len(value) - maxitems[key]
        value = value[:maxitems[key]]
        if value:
            comments.append('/* %d more */' % omitted)
        else:
            comments.append('/* %d item%s */' % (omitted, '' if omitted == 1 else 's'))

    if isinstance(value, dict):
        dropped = [k for k in value if k in omit]
        if dropped:
            comments.append('/* also %s */' % ', '.join(json.dumps(k) for k in dropped))
        members = []
        for k, v in value.items():
            if k in omit:
                continue
            name = json.dumps(k, ensure_ascii=False) + ': '
            members.append(name + pretty_json(v, abridge, width, indent + 2, k, len(name)))
        brackets = '{}'
    elif isinstance(value, list):
        members = [pretty_json(v, abridge, width, indent + 2, key) for v in value]
        brackets = '[]'
    else:
        return json.dumps(value, ensure_ascii=False)

    inline = brackets[0] + ' '.join([', '.join(members)] + comments).strip() + brackets[1]
    # The trailing comma after the value counts towards the line length too.
    if '\n' not in inline and indent + prefix + len(inline) + 1 <= width:
        return inline
    pad = ' ' * (indent + 2)
    lines = [pad + member + ',' for member in members]
    if not comments:
        lines[-1] = lines[-1][:-1]
    lines += [pad + comment for comment in comments]
    return brackets[0] + '\n' + '\n'.join(lines) + '\n' + ' ' * indent + brackets[1]


def render_json(rows, columns, directives, output):
    if len(rows) != 1 or len(columns) != 1:
        sys.exit('format: json needs a query returning exactly one row and one column, '
                 'but got %d rows and %d columns' % (len(rows), len(columns)))
    maxitems = {k: int(v) for k, v in split_pairs(directives.get('maxitems', '')).items()}
    omit = set(split_list(directives.get('omit', '')))
    width = int(directives.get('width', 70))
    value = json.loads(rows[0][0])
    path = os.path.splitext(output)[0] + '.json'
    with open(path, 'w', encoding='utf-8') as out:
        out.write(pretty_json(value, (maxitems, omit), width) + '\n')
    # \inputminted with no fontsize= takes the size of the group it is \input in, so the
    # call site in databases.tex chooses it, as it does for a generated table.
    return r'\inputminted{json}{%s}' % path.replace(os.sep, '/')


def run_cypher(database, query):
    """Run a Cypher query file against a Traverse database, via Node."""
    script = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'traverse-query.mjs')
    result = subprocess.run(['node', script, database, query], capture_output=True, text=True)
    if result.returncode != 0:
        sys.exit('%s: %s' % (query, result.stderr.strip()))
    output = json.loads(result.stdout)
    return output['columns'], [tuple(row) for row in output['rows']]


RENDERERS = {'table': render_table, 'scalar': render_scalar,
             'list': render_list, 'macros': render_macros}


def main():
    parser = argparse.ArgumentParser(description=__doc__.split('\n')[0])
    parser.add_argument('database', help='DuckDB database, e.g. moviedb-2025/movies.duckdb')
    parser.add_argument('query', help='query file, e.g. examples/kid-movies.sql')
    parser.add_argument('-o', '--output', help='output path (default: query file with .tex)')
    args = parser.parse_args()

    sql = open(args.query, encoding='utf-8').read()
    directives = parse_directives(sql)
    rounding = {}
    for pair in split_list(directives.get('round', '')):
        column, _, digits = pair.partition('=')
        rounding[column.strip()] = int(digits)

    if not os.path.exists(args.database):
        sys.exit('%s: no such database' % args.database)

    if args.query.endswith('.cypher'):
        columns, rows = run_cypher(args.database, args.query)
    else:
        connection = duckdb.connect(args.database, read_only=True)
        try:
            cursor = connection.execute(sql)
            columns = [d[0] for d in cursor.description]
            rows = cursor.fetchall()
        except duckdb.Error as error:
            sys.exit('%s: %s' % (args.query, error))
        finally:
            connection.close()

    if not rows and directives.get('allow-empty') != 'yes':
        sys.exit('%s: query returned no rows against %s.\nThe example data this query '
                 'refers to may have changed or been dropped; fix the query, or set\n'
                 '-- allow-empty: yes\nif an empty result is intended.'
                 % (args.query, args.database))

    fmt = directives.get('format')
    if fmt is None:
        fmt = 'scalar' if len(rows) == 1 and len(columns) == 1 else 'table'
    if fmt not in RENDERERS and fmt != 'json':
        sys.exit('%s: unknown format %r' % (args.query, fmt))
    if len(rows) > 1 and 'order by' not in sql.lower() and fmt != 'macros':
        print('%s: warning: multi-row query has no ORDER BY, so row order may change '
              'between database builds' % args.query, file=sys.stderr)

    if 'mark' in directives and fmt != 'table':
        sys.exit('%s: mark: only applies to format: table' % args.query)
    unknown = set(split_pairs(directives.get('mark', ''))) - set(columns)
    if unknown:
        sys.exit('%s: mark: names columns the query does not return: %s'
                 % (args.query, ', '.join(sorted(unknown))))

    output = args.output or os.path.splitext(args.query)[0] + '.tex'
    if fmt == 'json':
        body = render_json(rows, columns, directives, output)
    else:
        body = RENDERERS[fmt](rows, columns, directives, rounding)

    name = directives.get('name', os.path.basename(args.query))
    with open(output, 'w', encoding='utf-8') as out:
        out.write('%% %s\n' % name)
        out.write('%% Generated from %s by examples/render.py -- do not edit.\n'
                  % os.path.basename(args.query))
        out.write('%% Regenerate with: make examples\n'.replace('%%', '%'))
        out.write(body)
        out.write('%\n')
    print('%s -> %s (%d row%s)' % (args.query, output, len(rows),
                                   '' if len(rows) == 1 else 's'))


if __name__ == '__main__':
    main()
