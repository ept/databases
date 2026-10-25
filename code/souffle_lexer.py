"""A Pygments lexer for Souffle's dialect of Datalog, used by minted for the listings.

Pygments has no lexer for Souffle, and its Prolog lexer, the nearest relative, does not know
Souffle's // comments or its directives such as .decl. Use it in databases.tex as
\\inputminted{code/souffle_lexer.py:SouffleLexer -x}{code/foo.dl}; the -x tells minted (and
pygmentize) to load the lexer from this file.
"""

from pygments.lexer import RegexLexer, bygroups, words
from pygments.token import Comment, Keyword, Name, Number, Operator, Punctuation, String, Text, Whitespace


class SouffleLexer(RegexLexer):
    name = 'Souffle'
    aliases = ['souffle']
    filenames = ['*.dl']

    tokens = {
        'root': [
            (r'\s+', Whitespace),
            (r'//.*?$', Comment.Single),
            (r'/\*', Comment.Multiline, 'comment'),
            (r'#\s*(include|define|ifdef|ifndef|endif)\b.*?$', Comment.Preproc),
            # .input and .output are followed by a list of relation names
            (r'(\.(?:input|output|printsize))(\s+)', bygroups(Keyword.Declaration, Whitespace), 'relations'),
            # Other directives: .decl, .type, ...
            (r'\.[a-z_]+\b', Keyword.Declaration),
            # Aggregates and functors
            (words(('count', 'sum', 'min', 'max', 'mean', 'range'), suffix=r'\b'), Keyword),
            # Attribute types after a colon, e.g. "title: symbol"
            (r'(:)(\s*)(symbol|number|unsigned|float)\b', bygroups(Punctuation, Whitespace, Keyword.Type)),
            (r'"(\\\\|\\"|[^"])*"', String.Double),
            (r'-?\d+(\.\d+)?', Number),
            # A relation name is followed by an opening bracket
            (r'[A-Za-z_][A-Za-z0-9_]*(?=\s*\()', Name.Function),
            (r'_\b', Name.Builtin.Pseudo),
            (r'[A-Za-z_][A-Za-z0-9_]*', Name.Variable),
            (r':-|!=|<=|>=|[!<>=+\-*/%]', Operator),
            (r'[(),.:{}]', Punctuation),
            (r'.', Text),
        ],
        'relations': [
            (r'[A-Za-z_][A-Za-z0-9_]*', Name.Function),
            (r',', Punctuation),
            (r'[ \t]+|\n(?=[ \t])', Whitespace),
            (r'', Text, '#pop'),
        ],
        'comment': [
            (r'[^*]+', Comment.Multiline),
            (r'\*/', Comment.Multiline, '#pop'),
            (r'\*', Comment.Multiline),
        ],
    }
