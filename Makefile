# =============================================================================
# @file    Makefile
# @brief   Makefile for some steps in creating new releases on GitHub
# @date    %CREATION_DATE%
# @license Please see the file named LICENSE in the project directory
# @website https://github.com/caltechlibrary/%PROJECT_URLNAME%
# =============================================================================

.ONESHELL: 				# Run all commands in the same shell.
.SHELLFLAGS += -e			# Exit at the first error.

# Before we go any further, test if certain programs are available.
# The following is based on the approach posted by Jonathan Ben-Avraham to
# Stack Overflow in 2014 at https://stackoverflow.com/a/25668869

PROGRAMS_NEEDED = curl gh git jq sed
TEST := $(foreach p,$(PROGRAMS_NEEDED),\
	  $(if $(shell which $(p)),_,$(error Cannot find program "$(p)")))

# Set some basic variables.  These are quick to set; we set additional
# variables using "set-vars" but only when the others are needed.

name	:= $(strip $(shell awk -F "=" '/^name/ {print $$2}' setup.cfg))
version	:= $(strip $(shell awk -F "=" '/^version/ {print $$2}' setup.cfg))
url	:= $(strip $(shell awk -F "=" '/^url/ {print $$2}' setup.cfg))
desc	:= $(strip $(shell awk -F "=" '/^description / {print $$2}' setup.cfg))
author	:= $(strip $(shell awk -F "=" '/^author / {print $$2}' setup.cfg))
email	:= $(strip $(shell awk -F "=" '/^author_email/ {print $$2}' setup.cfg))
license	:= $(strip $(shell awk -F "=" '/^license / {print $$2}' setup.cfg))


# Print help if no command given ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

help:
	@echo 'Available commands:'
	@echo ''
	@echo 'make'
	@echo 'make help'
	@echo '  Print this summary of available commands.'
	@echo ''
	@echo 'make report'
	@echo '  Print variables set in this Makefile from various sources.'
	@echo '  This is useful to verify the values that have been parsed.'
	@echo ''
	@echo 'make release'
	@echo '  Do a release on GitHub.'
	@echo ''
	@echo 'make update-doi'
	@echo '  Update the DOI inside the README.md file.'
	@echo '  This is only to be done after doing a "make release".'
	@echo ''
	@echo 'make create-dist'
	@echo '  Create the distribution files for PyPI.'
	@echo '  Do this manually to check that everything looks okay before.'
	@echo '  try to do a "make test-pypi".'
	@echo ''
	@echo 'make test-pypi'
	@echo '  Upload distribution to test.pypi.org.'
	@echo '  Do this before doing "make pypi" for real.'
	@echo ''
	@echo 'make pypi'
	@echo '  Upload distribution to pypi.org.'
	@echo ''
	@echo 'make clean'
	@echo '  Clean up various files generated by this Makefile.'


# Gather values that we need ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.SILENT: set-vars
set-vars:
	$(info Gathering data -- this takes a few moments ...)
	$(eval branch    := $(shell git rev-parse --abbrev-ref HEAD))
	$(eval repo	 := $(strip $(shell gh repo view | head -1 | cut -f2 -d':')))
	$(eval api_url   := https://api.github.com/)
	$(eval id	 := $(shell curl -s $(github_api)/repos/$(repo) | jq '.id'))
	$(eval id_url	 := https://data.caltech.edu/badge/latestdoi/$(id))
	$(eval doi_url	 := $(shell curl -sILk $(id_url) | grep Locat | cut -f2 -d' '))
	$(eval doi	 := $(subst https://doi.org/,,$(doi_url)))
	$(eval doi_tail  := $(lastword $(subst ., ,$(doi))))
	$(eval init_file := $(name)/__init__.py)
	$(eval tmp_file  := $(shell mktemp /tmp/release-notes-$(name).XXXXXX))

report: set-vars
	@echo name	= $(name)
	@echo version	= $(version)
	@echo url	= $(url)
	@echo desc	= $(desc)
	@echo author	= $(author)
	@echo email	= $(email)
	@echo license	= $(license)
	@echo branch	= $(branch)
	@echo repo	= $(repo)
	@echo id	= $(id)
	@echo id_url	= $(id_url)
	@echo doi_url	= $(doi_url)
	@echo doi	= $(doi)
	@echo doi_tail	= $(doi_tail)
	@echo init_file = $(init_file)
	@echo tmp_file	= $(tmp_file)


# make release ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

release: | test-branch release-on-github print-instructions

test-branch: set-vars
ifneq ($(branch),main)
	$(error Current git branch != main. Merge changes into main first!)
endif

update-init:;
	@sed -i .bak -e "s|^\(__version__ *=\).*|\1 '$(version)'|"  $(init_file)
	@sed -i .bak -e "s|^\(__description__ *=\).*|\1 '$(desc)'|" $(init_file)
	@sed -i .bak -e "s|^\(__url__ *=\).*|\1 '$(url)'|"	    $(init_file)
	@sed -i .bak -e "s|^\(__author__ *=\).*|\1 '$(author)'|"    $(init_file)
	@sed -i .bak -e "s|^\(__email__ *=\).*|\1 '$(email)'|"	    $(init_file)
	@sed -i .bak -e "s|^\(__license__ *=\).*|\1 '$(license)'|"  $(init_file)

update-codemeta:;
	@sed -i .bak -e "/version/ s/[0-9].[0-9][0-9]*.[0-9][0-9]*/$(version)/" codemeta.json

edited := codemeta.json $(init_file)

check-in-updated-files: set-vars
	git add $(edited)
	git diff-index --quiet HEAD $(edited) || \
	    git commit -m"Update stored version number" $(edited)

release-on-github: | set-vars update-init update-codemeta check-in-updated-files
	git push -v --all
	git push -v --tags
	$(info ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓)
	$(info ┃ Write release notes in the file that will be opened in your editor ┃)
	$(info ┃ then save and close the file to complete this release process.     ┃)
	$(info ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛)
	sleep 2
	$(EDITOR) $(tmp_file)
	gh release create v$(version) -t "Release $(version)" -F $(tmp_file)

print-instructions:;
	$(info ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓)
	$(info ┃ Next steps:                                                        ┃)
	$(info ┃ 1. Visit https://github.com/$(repo)/releases )
	$(info ┃ 2. Double-check the release                                        ┃)
	$(info ┃ 3. Wait a few seconds to let web services do their work            ┃)
	$(info ┃ 4. Run "make update-doi" to update the DOI in README.md            ┃)
	$(info ┃ 5. Run "make create-dist" and check the distribution for problems  ┃)
	$(info ┃ 6. Run "make test-pypi" to push to test.pypi.org                   ┃)
	$(info ┃ 7. Double-check https://test.pypi.org/$(repo) )
	$(info ┃ 8. Run "make pypi" to push to pypi for real                        ┃)
	$(info ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛)
	@echo ""

update-doi: 
	sed -i .bak -e 's|/api/record/[0-9]\{1,\}|/api/record/$(doi_tail)|' README.md
	sed -i .bak -e 's|edu/records/[0-9]\{1,\}|edu/records/$(doi_tail)|' README.md
	git add README.md
	git diff-index --quiet HEAD README.md || \
	    (git commit -m"Update DOI" README.md && git push -v --all)

create-dist: clean
	python3 setup.py sdist bdist_wheel
	python3 -m twine check dist/$(name)-$(version).tar.gz
	python3 -m twine check dist/$(name)-$(version)-py3-none-any.whl

test-pypi: create-dist
	python3 -m twine upload --repository testpypi dist/$(name)-$(version)*.{whl,gz}

pypi: create-dist
	python3 -m twine upload dist/$(name)-$(version)*.{gz,whl}


# Cleanup and miscellaneous directives ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

clean: clean-dist clean-build clean-release clean-other

clean-dist:;
	-rm -fr dist/$(name) dist/$(name)-$(version).tar.gz \
	    dist/$(name)-$(version)-py3-none-any.whl dist/binary

clean-build:;
	-rm -rf build

clean-release:;
	-rm -rf $(name).egg-info codemeta.json.bak $(init_file).bak README.md.bak

clean-other:;
	-find ./ -name '*.pyc' -exec rm -f {} \;
	-find ./ -name '__pycache__' -exec rm -rf {} \;
	-find ./ -name 'Thumbs.db' -exec rm -f {} \;
	-rm -rf .cache

.PHONY: release release-on-github update-init update-codemeta \
	print-instructions create-dist clean test-pypi pypi