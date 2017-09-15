#!/usr/bin/env bash

# Path to the tex file
TEX_PATH="Hello.tex"
PDF_NAME="generated"
# Note that GITHUB_API_KEY should also be specified through Travis

echo "Create new latex build\n"

mkdir _latex_build
pdflatex -output-directory _latex_build -jobname=generated ${TEX_PATH}

echo "Create New Release\n"

API_JSON="$(printf '{"tag_name": "v%s","target_commitish": "master","name": "v%s","body": "Automatic Release v%s","draft": false,"prerelease": false}' $TRAVIS_BUILD_NUMBER $TRAVIS_BUILD_NUMBER $TRAVIS_BUILD_NUMBER)"
newRelease="$(curl --data "$API_JSON" https://api.github.com/repos/$TRAVIS_REPO_SLUG/releases?access_token=$GITHUB_API_KEY)"
rID="$(echo "$newRelease" | jq ".id")"



echo "Push pdf to $rID"
curl "https://uploads.github.com/repos/${TRAVIS_REPO_SLUG}/releases/${rID}/assets?access_token=${GITHUB_API_KEY}&name=${PDF_NAME}-v${TRAVIS_BUILD_NUMBER}.pdf" --header 'Content-Type: application/pdf' --upload-file _latex_build/generated.pdf -X POST

echo -e "Done\n"
