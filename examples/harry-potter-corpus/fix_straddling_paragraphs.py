#! /usr/bin/env python3

def count_sentences(nlp, text: str) -> int:
    return sum(1 for _ in nlp(replace_stylish_quotes(text)).sents)

def replace_stylish_quotes(text: str) -> str:
    return text.replace("“", "").replace("”", "").replace("’", "\'")

if __name__ == "__main__":
    import sys
    import spacy
    nlp = spacy.load('en_core_web_sm')
    accum = ''
    accum_sentence_count = 0
    for line in sys.stdin:
        piece = line.rstrip('\n')
        sentence_count = count_sentences(nlp, piece)
        concatenation = accum.rstrip(' ') + ' ' + piece
        concatenation_sentence_count = count_sentences(nlp, concatenation)
        if concatenation_sentence_count == accum_sentence_count + sentence_count:
            # expected boundary between paragraphs: prints last paragraph and resets sentence count:
            print(accum)
            accum = piece
            accum_sentence_count = sentence_count
        else:
            # straddling paragraph: accumulates text and sentence count:
            accum = concatenation
            accum_sentence_count = concatenation_sentence_count 
    print(accum)

