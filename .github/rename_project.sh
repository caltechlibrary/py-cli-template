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

echo "Author name: $author";
echo "Project name: $name";
echo "Project URL name: $urlname";
echo "Description: $description";

echo "Renaming project..."

creation_date=$(date +"%Y-%m-%d")
creation_year=$(date +"%Y")

for filename in $(git ls-files)
do
    sed -i "s/%AUTHOR_NAME%/$author/g" $filename
    sed -i "s/%PROJECT_NAME%/$name/g" $filename
    sed -i "s/%PROJECT_URLNAME%/$urlname/g" $filename
    sed -i "s/%PROJECT_DESCRIPTION%/$description/g" $filename
    sed -i "s/%CREATION_DATE%/$creation_date/g" $filename
    sed -i "s/%CREATION_YEAR%/$creation_year/g" $filename
    echo "Performed substitutions in $filename"
done

mv project_name $name

# This command runs only once on GHA!
rm -rf .github/template.yml
