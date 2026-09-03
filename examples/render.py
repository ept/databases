#!/usr/bin/env python3
"""Render the result of a SQL query as a LaTeX fragment.

Usage:  python3 examples/render.py <database.sqlite> <examples/query.sql> [-o out.tex]

Runs the query in <query.sql> against <database.sqlite> and writes the formatted
result to <examples/query.tex> (or the path given with -o), ready to be pulled into
databases.tex with \\input.

Only data that depends on the *contents* of the example database belongs here.
Anything that follows from the schema alone (the schema diagram, the CREATE TABLE
listings) is hard-coded in databases.tex, because the schema does not change from
year to year.

Formatting is controlled by `-- key: value` directives in comments at the top of the
.sql file:

  name        Human-readable description, copied into the output as a comment.
  format      table   a complete `tabular` environment (default for multi-cell results)
              scalar  just the value, for use inline in a sentence (default for 1x1)
              list    comma-separated inline list of a single column
              macros  \\newcommand definitions from a (name, value) result
  align       One letter (l/r/c) per column, e.g. `llrlr`.
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
  prefix      Macro-name prefix for `format: macros`.
  mark        Comma-separated col=prefix pairs, e.g. `movie_id=mv`. Wraps that column's
              cells in \tikzmarknode so a later [remember picture,overlay] tikzpicture can
              draw on them: <prefix>0 is the header cell, <prefix>1 the first data row, and
              so on. Used for the circles and braces on the key slides. Prefixes must be
              unique across the whole document, since the names are global.
  allow-empty yes, to permit a query that returns no rows (normally an error).
"""

import argparse
import os
import re
import sqlite3
import sys

SPECIALS = {'\\': r'\textbackslash{}', '{': r'\{', '}': r'\}', '$': r'\$',
            '&': r'\&', '#': r'\#', '_': r'\_', '%': r'\%',
            '^': r'\^{}', '~': r'\~{}'}


def latex_escape(text):
    return ''.join(SPECIALS.get(ch, ch) for ch in text)


def parse_directives(sql):
    """Read `-- key: value` lines from the top of the file."""
    directives = {}
    for line in sql.splitlines():
        stripped = line.strip()
        if not stripped:
            continue
        if not stripped.startswith('--'):
            break
        match = re.match(r'--\s*([a-z-]+)\s*:\s*(.*)$', stripped)
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
        numeric = values and all(isinstance(v, (int, float)) for v in values)
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
    if len(columns) != 1:
        sys.exit('format: list needs a query returning exactly one column, got %d'
                 % len(columns))
    items = [format_cell(row[0], columns[0], directives, rounding) for row in rows]
    conjunction = directives.get('conjunction')
    if conjunction and len(items) > 1:
        return ', '.join(items[:-1]) + ', %s %s' % (conjunction, items[-1])
    return ', '.join(items)


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


RENDERERS = {'table': render_table, 'scalar': render_scalar,
             'list': render_list, 'macros': render_macros}


def main():
    parser = argparse.ArgumentParser(description=__doc__.split('\n')[0])
    parser.add_argument('database', help='SQLite database, e.g. moviedb-2025/movies.sqlite')
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

    connection = sqlite3.connect('file:%s?mode=ro' % args.database, uri=True)
    try:
        cursor = connection.execute(sql)
        columns = [d[0] for d in cursor.description]
        rows = cursor.fetchall()
    except sqlite3.Error as error:
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
    if fmt not in RENDERERS:
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

    body = RENDERERS[fmt](rows, columns, directives, rounding)

    output = args.output or os.path.splitext(args.query)[0] + '.tex'
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
