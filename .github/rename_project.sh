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

while getopts a:d:e:m:r: flag; do
    case "${flag}" in
        a) author=${OPTARG};;
        d) description=${OPTARG};;
        e) email=${OPTARG};;
        m) module_name=${OPTARG};;
        r) repo_name=${OPTARG};;
    esac
done

first_name=$(echo $author | /usr/bin/awk '{print $1}' | tr -d '"')
family_name=$(echo $author | /usr/bin/awk '{print $NF}' | tr -d '"')

creation_date=$(date +"%Y-%m-%d")
creation_year=$(date +"%Y")

echo "Author name: $author"
echo "Author first name: $first_name"
echo "Author family name: $family_name"
echo "Author email: $email"
echo "Repo name: $repo_name"
echo "Module name: $module_name"
echo "Description: $description"
echo "Creation date: $creation_date"
echo "Creation year: $creation_year"

echo "Performing substitutions in files ..."

for filename in $(git ls-files)
do
    sed -i "s/%AUTHOR_NAME%/$author/g" $filename
    sed -i "s/%AUTHOR_EMAIL%/$email/g" $filename
    sed -i "s/%AUTHOR_FIRST_NAME%/$first_name/g" $filename
    sed -i "s/%AUTHOR_FAMILY_NAME%/$family_name/g" $filename
    sed -i "s/%REPO_NAME%/$repo_name/g" $filename
    sed -i "s/%DESCRIPTION%/$description/g" $filename
    sed -i "s/%MODULE_NAME%/$module_name/g" $filename
    sed -i "s/%CREATION_DATE%/$creation_date/g" $filename
    sed -i "s/%CREATION_YEAR%/$creation_year/g" $filename
    echo "Finished substitutions in $filename"
done

echo "Renaming files and directories ..."

mv module_name $module_name
rm -f codemeta.json
mv codemeta-TEMPLATE.json codemeta.json
rm -f CITATION.cff
mv CITATION-TEMPLATE.cff CITATION.cff

echo "Renaming ... Done."
