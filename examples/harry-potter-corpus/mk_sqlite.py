
def translate(documents_tsv_file_path: str, documents_sqlite_file_path: str):
    from sqlitedict import SqliteDict
    with open(documents_tsv_file_path, "r", encoding="utf-8") as documents_file, SqliteDict(
        documents_sqlite_file_path, tablename="documents"
    ) as documents_db:
        next(documents_file)
        lines = 0
        for line in documents_file:
            document_idx, text, title = line.rstrip("\n").split("\t")
            documents_db[document_idx] = {
                "document_id": document_idx,
                "text": text,
                "title": title,
            }
            lines = lines + 1
            if lines % 10000 == 0:
                print(f"Translated {lines} lines...", file=sys.stderr, end='\r')

        print(f"Translated {lines} lines.", file=sys.stderr, end='\r')
        print("", file=sys.stderr)
        # Step 3.c: Commit to save documents_db
        documents_db.commit()

if __name__ == "__main__":
    import sys
    import os
    # Check argument present
    if len(sys.argv) < 3:
        print(f"Usage: python mk_sqlite.py <tsv-file> <sqlite-file>", file=sys.stderr)
        sys.exit(1)

    documents_tsv_file_path = os.path.abspath(sys.argv[1])

    # Check input file present
    if not os.path.isfile(documents_tsv_file_path):
        print(f"Couldn't find {documents_tsv_file_path}", file=sys.stderr)
        sys.exit(1)

    documents_sqlite_file_path = os.path.abspath(sys.argv[2])

    translate(documents_tsv_file_path, documents_sqlite_file_path)
    print(f"Successfully translated into {documents_sqlite_file_path}", file=sys.stderr)

