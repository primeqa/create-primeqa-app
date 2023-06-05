#! /usr/bin/env python3

from typing import Any, Generator
import sys
from io import StringIO
import itertools
import re
import spacy
from spacy.language import Language
import csv

def log(stuff: Any):
    """Logs str of values to stderr."""
    print(str(stuff), file=sys.stderr)

def lines_from_file(file_name: str) -> Generator[str, None, None]:
    """Reads a file and yields its lines."""
    log(f"Processing {file_name}...")
    for line in open(file_name, "r", encoding="utf-8"):
        yield line

def strip_newline(lines: Generator[str, None, None]) -> Generator[str, None, None]:
    """Removes trailing newlines from lines."""
    for line in lines:
        yield line.rstrip("\n")

def skip(pattern: str, lines: Generator[str, None, None]) -> Generator[str, None, None]:
    """Skips lines matching the pattern."""
    for line in lines:
        if not re.search(pattern, line):
            yield line

def fix_straddling_paragraphs(nlp: Language, lines: Generator[str, None, None]) -> Generator[str, None, None]:
    """Combines lines according to sentence continuity"""
    def _replace_stylish_quotes(text: str) -> str:
        """Replaces stylish quotes and apostrophes."""
        return text.replace("“", "").replace("”", "").replace("’", "\'")

    def _count_sentences(text: str) -> int:
        """Counts the quantity of sentences in a fragment."""
        return sum(1 for _ in nlp(_replace_stylish_quotes(text)).sents)
    
    accum: str = ""
    accum_sentence_count: int = 0
    for line in lines:
        sentence_count = _count_sentences(line)
        concatenation = accum.rstrip(" ") + " " + line
        concatenation_sentence_count = _count_sentences(concatenation)
        if concatenation_sentence_count == accum_sentence_count + sentence_count:
            # expected boundary between paragraphs: returns last paragraph and resets sentence count:
            yield accum
            accum = line
            accum_sentence_count = sentence_count
        else:
            # straddling paragraph: accumulates text and sentence count:
            accum = concatenation
            accum_sentence_count = concatenation_sentence_count 
    yield accum

def word_qty(doc) -> int:
    """Counts words from text fragment."""
    count: int = 0
    for i in doc:
        if not (i.is_space or i.is_punct):
            count = count + 1
    return count

def combine_up_to_n_words(nlp: Language, n: int, lines: Generator[str, None, None]) -> Generator[str, None, None]:
    """Combines contiguous short paragraphs up to n words."""
    par: str = ""
    count: int = 0
    for line in lines:
        current_count: int = word_qty(nlp(line))
        if count + current_count <= n:
            if par != "":
                line = " " + line
            par = par.rstrip(" ") + line
            count = count + current_count
        else:
            yield par
            par = line
            count = current_count
    if par != "":
        yield par
    par = ""
    count = 0

def split_by_sentences_up_to_n_words(nlp: Language, n: int, lines: Generator[str, None, None]) -> Generator[str, None, None]:
    """Splits paragraphs longer than n words in sentence boundaries."""
    for line in lines:
        doc = nlp(line)
        word_count: int = word_qty(doc)
        if word_count > n:
            accum: str = ""
            word_count_accum: int = 0
            for sent in doc.sents:
                sentence = sent.text
                sentence_word_count = word_qty(sent)
                if word_count_accum + sentence_word_count < n:
                    if accum != "":
                        accum = accum.rstrip() + " "
                    accum = accum + sentence
                    word_count_accum = word_count_accum + sentence_word_count
                else:
                    yield accum
                    accum = sentence
                    word_count_accum = sentence_word_count
            if accum != "":
                yield accum
        else:
            yield line

def number_lines(lines: Generator[str, None, None]) -> Generator[str, None, None]:
    """Prepends a tab-separated line number to a text line."""
    count: int = 1
    for line in lines:
        yield str(count) + "\t" + line
        count = count + 1

def to_tsv(title_prefix: str, lines: Generator[str, None, None]) -> Generator[str, None, None]:
    """Generates TSV lines from an input generator, appending title and paragraph numbering."""
    buffer = StringIO()
    writer = csv.writer(buffer, delimiter='\t', lineterminator='\n')

    def _stringify(data: list[str]) -> str:
        """Extracts the TSV serialization from the writer as a string."""
        writer.writerow(data)
        value: str = buffer.getvalue().strip("\r\n")
        buffer.seek(0)
        buffer.truncate(0)
        return value

    counter: int = 1
    for line in lines:
        data: list[str] = [ line, title_prefix + " Paragraph " + str(counter) ]
        yield _stringify(data)
        counter = counter + 1

def write(out, lines: Generator[str, None, None]):
    """Writes lines to output stream, appending a newline."""
    for line in lines:
        out.write(line + "\n")

if __name__ == "__main__":
    nlp: Language = spacy.load("en_core_web_sm")
    WORD_QTY: int = 180
    files: list[str] = sys.argv[1:]
    out = sys.stdout

    # Adds the header to the file
    out.write("id\ttext\ttitle\n")

    all_lines = itertools.chain()
    for file_name in files:
        # For each book:
        # Reads line by line.
        lines = lines_from_file(file_name)
        # Removes newline at the end of each line.
        lines = strip_newline(lines)
        # Skips page number footer by regex matching.
        lines = skip(r"^Page \|\s*[0-9]+ .*$", lines)
        lines = skip(r"^P a g e.*$", lines)
        lines = skip(r"P.*Rowling", lines)
        # Skips blank lines.
        lines = skip(r"^\s+$", lines)
        # Fixes pagebreak-straddling paragraphs checking sentence continuity (one paragraph per line up to this point).
        lines = fix_straddling_paragraphs(nlp, lines)
        # Combines contiguous short paragraphs as long as the result doesn't exceed WORD_QTY words.
        lines = combine_up_to_n_words(nlp, WORD_QTY, lines)
        # Splits paragraphs longer than WORD_QTY words, keeping whole sentences.
        lines = split_by_sentences_up_to_n_words(nlp, WORD_QTY, lines)

        # Formats each fragment as TSV appending "Book<N> Paragraph <M>" as title.
        book_name = re.sub(r"\.[a-zA-Z0-9]+$", "", file_name)
        lines = to_tsv(book_name, lines)

        # Concatenates book lines
        all_lines = itertools.chain(all_lines, lines)

    # Prepends line numbers (will be used as ids)
    all_lines = number_lines(all_lines)
    write(out, all_lines)
