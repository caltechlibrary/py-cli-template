from os import path
import sys

try:
    thisdir = path.dirname(path.abspath(__file__))
    sys.path.append(path.join(thisdir, '..'))
except Exception:                       # noqa: PIE786
    sys.path.append('..')


def test_version():
    """Test version import."""
    from %PROJECT_NAME% import __version__
    assert __version__


def test_print_version(capsys):
    from %PROJECT_NAME% import print_version
    print_version()
    captured = capsys.readouterr()
    assert 'URL' in captured.out
