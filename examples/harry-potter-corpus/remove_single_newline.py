#! /usr/bin/env python3

if __name__ == "__main__":
    import sys
    accum=''
    for line in sys.stdin:
        if line != '\n':
            accum = accum + line.rstrip('\n')
        else:
            print(accum)
            accum = ''
    if accum != '':
        print(accum)

