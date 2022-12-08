#! /usr/bin/env bash

readonly PROGNAME=$(basename $0)
readonly E_BADARGS=85

if [[ $# -lt 1 ]]; then
  >&2 echo "usage: ${PROGNAME} model-file store-dir";
  exit ${E_BADARGS};
fi

readonly CHECKPOINT_FILE="$(realpath ${1})"
readonly CHECKPOINT_FILE_NAME="$(basename ${CHECKPOINT_FILE})"

mkdir -p "${2}"
readonly STORE="$(realpath ${2})"

readonly CHECKPOINTS_DIR="$(realpath ${STORE}/checkpoints)"

readonly STAT=$(date +%Y%m%d%H%M%S)

>&2 echo "Creating checkpoints directory, if it doesn't exist..."

mkdir "${CHECKPOINTS_DIR}" 2> /dev/null && >&2 echo "Checkpoints directory successfully created" || >&2 echo "Checkpoints directory already exists"

readonly CHECKPOINT_DIR="${CHECKPOINTS_DIR}/ColBERTIndexer_${STAT}"

>&2 echo "Creating checkpoint directory, if it doesn't exist..."

mkdir "${CHECKPOINT_DIR}" 2> /dev/null || >&2 echo "Checkpoint directory already exists"

>&2 echo "Moving checkpoint file..."

mv "${CHECKPOINT_FILE}" "${CHECKPOINT_DIR}/${CHECKPOINT_FILE_NAME}"

echo "${CHECKPOINT_DIR}/${CHECKPOINT_FILE_NAME}"

