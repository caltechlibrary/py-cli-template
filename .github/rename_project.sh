#!/usr/bin/env bash
# =============================================================================
# @file    rename_project.sh
# @brief   Shell script used in GitHub workflow for naming new projects
# @created 2021-10-14
# @license Please see the file named LICENSE in the project directory
# @website https://github.com/caltechlibrary/py-cli-template
#
# This file was originally based on the file of the same name in the repo
# https://github.com/rochacbruno/python-project-template by Bruno Rocha.
# The original file was copied on 2021-10-14.
# =============================================================================

while getopts a:n:u:d: flag
do
    case "${flag}" in
        a) author=${OPTARG};;
        n) name=${OPTARG};;
        u) urlname=${OPTARG};;
        d) description=${OPTARG};;
    esac
done

echo "Author: $author";
echo "Project Name: $name";
echo "Project URL name: $urlname";
echo "Description: $description";

echo "Renaming project..."

original_author="%AUTHOR_NAME%"
original_name="%PROJECT_NAME%"
original_urlname="%PROJECT_URLNAME%"
original_description="%PROJECT_DESCRIPTION%"

creation_date=$(date +"%Y-%m-%d")
creation_year=$(date +"%Y")

for filename in $(git ls-files)
do
    sed -i "s/$original_author/$author/g" $filename
    sed -i "s/$original_name/$name/g" $filename
    sed -i "s/$original_urlname/$urlname/g" $filename
    sed -i "s/$original_description/$description/g" $filename

    sed -i "s/%CREATION_DATE%/$creation_date/g" $filename
    sed -i "s/%CREATION_YEAR%/$creation_year/g" $filename
    echo "Renamed $filename"
done

mv project_name $name

# This command runs only once on GHA!
rm -rf .github/template.yml
