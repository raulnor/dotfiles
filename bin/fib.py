#!/usr/bin/env python3

import functools, sys

@functools.lru_cache(maxsize=1000)
def fib(n):
    if n <= 1:
        return n
    else:
        return fib(n-1) + fib(n-2)

if __name__ == "__main__":
    if len(sys.argv) >= 2:
        for n in sys.argv[1:]:
            print(fib(int(n)))
    else:
        while True:
            n = int(input("n = "))
            print("fib(n) = %s" % (fib(n)))
