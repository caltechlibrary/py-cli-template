from os import path
import plac
import sys

try:
    thisdir = path.dirname(path.abspath(__file__))
    sys.path.append(path.join(thisdir, '..'))
except Exception:                       # noqa: PIE786
    sys.path.append('..')


def test_usage_help(capsys):
    from %PROJECT_NAME%.__main__ import main
    with plac.Interpreter(main) as i:
        i.check('-h', '')
