#! /usr/bin/env bash

readonly PROGNAME=$(basename $0)
readonly E_BADARGS=85

if [[ $# -lt 3 ]]; then
  >&2 echo "Usage: ${PROGNAME} checkpoint-file tsv-collection-file store-dir";
  exit ${E_BADARGS};
fi

if ! python -c "import primeqa" 2> /dev/null; then
  >&2 echo "PrimeQA needs to be installed in this environment: pip install primeqa";
  exit 1;
fi

if ! "${JAVA_HOME}"/bin/javac -version &> /dev/null; then
  >&2 echo "JAVA_HOME environment variable must be set with the path of a JDK 11 installation"
  exit 1;
fi

readonly UUID="$(cat /proc/sys/kernel/random/uuid)"
readonly CHECKPOINT="$(realpath ${1})"
readonly CHECKPOINT_NAME="$(basename ${CHECKPOINT})"
readonly COLLECTION="$(realpath ${2})"
readonly STORE="$(realpath ${3})"
readonly STORE_NAME="$(basename ${STORE})"
readonly ROOT="$(dirname ${STORE})"
readonly INDEXES_DIR="$(realpath ${STORE}/indexes)"

>&2 echo "Creating indexes directory, if it doesn't exist..."

mkdir "${INDEXES_DIR}" 2> /dev/null && >&2 echo "Indexes directory successfully created" || >&2 echo "Indexes directory already exists"

readonly INDEX_DIR="${INDEXES_DIR}/${UUID}"

mkdir "${INDEX_DIR}" 2> /dev/null && >&2 echo "Index directory successfully created" || >&2 echo "Index directory already exists"

mkdir "${INDEX_DIR}/index" 2> /dev/null && >&2 echo "Proper index directory successfully created" || >&2 echo "Proper index directory already exists"

>&2 echo "Indexing corpus..."

python -m primeqa.ir.run_ir \
    --do_index \
    --engine_type ColBERT \
    --amp \
    --doc_maxlen 180 \
    --mask-punctuation \
    --bsize 256 \
    --model_name_or_path "${CHECKPOINT}" \
    --collection "${COLLECTION}" \
    --index_name ${UUID} \
    --experiment "${STORE_NAME}" \
    --root "${ROOT}" \
    --nbits 4

mv "${INDEX_DIR}"/*.pt "${INDEX_DIR}"/*.json "${INDEX_DIR}"/index/

>&2 echo "Creating ${INDEX_DIR}/information.json..."

cat << EOF > ${INDEX_DIR}/information.json
{
  "index_id": "${UUID}",
  "checkpoint": "${CHECKPOINT_NAME}",
  "status": "READY"
}
EOF

>&2 echo "Created ${INDEX_DIR}/information.json..."

>&2 echo "Copying documents file..."
cp "${COLLECTION}" "${INDEX_DIR}/documents.tsv"

>&2 echo "Translating documents into sqlite file..."
python mk_sqlite.py "${COLLECTION}" "${INDEX_DIR}/documents.sqlite" || >&2 echo "Translation process requires Python 3 and sqldict. Consider using a virtual environment and run: pip install sqldict"

