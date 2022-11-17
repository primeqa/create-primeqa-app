#! /usr/bin/env python3

if __name__ == "__main__":
    import sys
    import csv

    # Check argument present
    if len(sys.argv) < 2:
        print(f"Usage: python to_tsv.py <title_prefix>", file=sys.stderr)
        sys.exit(1)

    title_prefix = sys.argv[1]

    doc = csv.writer(sys.stdout, delimiter='\t', lineterminator='\n')
    counter = 1
    for line in sys.stdin:
        line = line.rstrip('\n')
        data = [ line, title_prefix + " Paragraph " + str(counter) ]
        doc.writerow(data)
        counter = counter + 1

