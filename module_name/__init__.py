'''
__init__.py for %MODULE_NAME%

Copyright
---------

Copyright (c) %CREATION_YEAR% by the California Institute of Technology.  This code
is open-source software released under a BSD-type license.  Please see the
file "LICENSE" for more information.
'''

# Package metadata
# .............................................................................
#
#  ╭────────────────────── Notice ── Notice ── Notice ─────────────────────╮
#  |    The following values are automatically updated at every release    |
#  |    by the Makefile. Manual changes to these values will be lost.      |
#  ╰────────────────────── Notice ── Notice ── Notice ─────────────────────╯

__version__     = '0.0.0'
__description__ = '%DESCRIPTION%'
__url__         = 'https://github.com/caltechlibrary/%REPO_NAME%'
__author__      = '%AUTHOR_NAME%'
__email__       = 'helpdesk@library.caltech.edu'
__license__     = 'https://github.com/caltechlibrary/%REPO_NAME%/blob/main/LICENSE'

# Miscellaneous utilities.
# .............................................................................

def print_version():
    print(f'{__name__} version {__version__}')
    print(f'Authors: {__author__}')
    print(f'URL: {__url__}')
    print(f'License: {__license__}')
