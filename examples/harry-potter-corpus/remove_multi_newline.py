#! /usr/bin/env python3

if __name__ == "__main__":
    from sys import stdin
    last='dummy'
    for line in stdin:
        if line != '\n':
            print(line, end='')
        elif last != '\n':
            print('\n', end='')
        last = line

