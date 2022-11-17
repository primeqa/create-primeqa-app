#! /usr/bin/env python3

def word_qty(nlp, text: str) -> int:
    doc = nlp(text)
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
        print(f"Usage: python combine_up_to_n_words.py <positive_integer>", file=sys.stderr)
        sys.exit(1)

    n = int(sys.argv[1])

    nlp = spacy.load('en_core_web_sm')
    par = ''
    count = 0
    for line in sys.stdin:
        current_par = line.rstrip('\n')
        current_count = word_qty(nlp, current_par)
        if count + current_count <= n:
            if par != '':
                current_par = ' ' + current_par
            par = par + current_par
            count = count + current_count
        else:
            print(par)
            par = current_par
            count = current_count
    print(par)

