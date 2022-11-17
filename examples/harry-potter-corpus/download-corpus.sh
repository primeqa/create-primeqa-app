#! /usr/bin/env bash

readonly CORPUS_KAGGLE_USERNAME=balabaskar

readonly CORPUS_NAME=harry-potter-books-corpora-part-1-7

readonly ARCHIVE_NAME="${CORPUS_NAME}".zip

if [[ ! -f "kaggle.json" ]]; then
  >&2 echo "Unable to find kaggle.json credentials file. It can be downloaded by clicking the \"Create New API Token\" in the \"API\" section in https://www.kaggle.com/YOURUSER/account";
  exit 126;
fi

>&2 echo Downloading corpus from Kaggle...

KAGGLE_USERNAME=$(cat kaggle.json | python -c "import sys, json; print(json.load(sys.stdin)['username'])") \
  KAGGLE_KEY=$(cat kaggle.json | python -c "import sys, json; print(json.load(sys.stdin)['key'])") \
  kaggle datasets download -d "${CORPUS_KAGGLE_USERNAME}"/"${CORPUS_NAME}"

>&2 echo Extracting files...

unzip "${ARCHIVE_NAME}"

