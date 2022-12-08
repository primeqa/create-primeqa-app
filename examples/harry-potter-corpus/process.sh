#! /usr/bin/env bash

# For each book:
#   First three seds: Removes page number footer by regex matching.
#   Fourth sed: Remove sole blanks from lines.
#   remove_multi_newline.py: Collapses three or more contiguous newlines into a single empty line (two contiguous newlines).
#   remove_single_newline.py: Removes single newlines so paragraphs get consolidated into the same line, one per line.
#   fix_straddling_paragraphs.py: Fixes pagebreak-straddling paragraphs checking sentence continuity (one paragraph per line up to this point).
#   combine_up_to_n_words.py: Combines contiguous short paragraphs as long as the result doesn't exceed WORD_QTY words (180 by default, if not provided).
#   split_by_sentences_up_to_n_words.py: Splits paragraphs longer than WORD_QTY words, keeping whole sentences.
#   to_tsv.py: Formats each fragment as TSV appending "Book<N> Paragraph <M>" as title.

readonly WORD_QTY="${1:-180}"

for book in Book*.txt; do
  >&2 echo "Processing ${book}..."
  cat "${book}" \
    | sed -E 's/^Page \|\s*[0-9]+ .*$//g' \
    | sed -E 's/^P a g e.*$//g' \
    | sed -E 's/P.*Rowling//g' \
    | sed -E 's/^\s+$//g' \
    | ./remove_multi_newline.py \
    | ./remove_single_newline.py \
    | ./fix_straddling_paragraphs.py \
    | ./combine_up_to_n_words.py "${WORD_QTY}" \
    | ./split_by_sentences_up_to_n_words.py "${WORD_QTY}" \
    | ./to_tsv.py "${book%.*}" \
    | cat > "${book%.*}.tsv"
done

# cat: Concatenates book results
# nl: Prepends line numbers (will be used as ids)
# sed: Removes nl padding spaces at the beginning of each line
# echo;cat: Adds the header to the file
# cat: Concatenates each book's result into a single `corpus.tsv` file.

cat Book*.tsv \
  | nl \
  | sed 's/^ *//g' \
  | { echo -e 'id\ttext\ttitle'; cat; } \
  | cat > corpus.tsv

>&2 echo "corpus.tsv successfully generated."

