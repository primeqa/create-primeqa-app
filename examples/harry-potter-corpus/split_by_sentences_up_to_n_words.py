#! /usr/bin/env python3

def word_qty(doc) -> int:
    count = 0
    for i in doc:
        if not (i.is_space or i.is_punct):
            count = count + 1
    return count

if __name__ == "__main__":
    import sys
    import spacy

    # Check argument present
    if len(sys.argv) < 2:
        print(f"Usage: python split_by_sentences_up_to_n_words.py <positive_integer>", file=sys.stderr)
        sys.exit(1)

    n = int(sys.argv[1])

    nlp = spacy.load('en_core_web_sm')
    for line in sys.stdin:
        paragraph = line.rstrip('\n')
        doc = nlp(paragraph)
        word_count = word_qty(doc)
        if word_count > n:
            accum = ''
            word_count_accum = 0
            for sent in doc.sents:
                sentence = sent.text
                sentence_word_count = word_qty(sent)
                if word_count_accum + sentence_word_count < n:
                    if accum != '':
                        accum = accum.rstrip() + ' '
                    accum = accum + sentence
                    word_count_accum = word_count_accum + sentence_word_count
                else:
                    print(accum)
                    accum = sentence
                    word_count_accum = sentence_word_count
            if accum != '':
                print(accum)
        else:
            print(paragraph)

