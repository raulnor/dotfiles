#!/usr/bin/env python3

def convert_integer(x: int) -> str:
    if x % 15 == 0:
        return "FizzBuzz"
    if x % 3 == 0:
        return "Fizz"
    if x % 5 == 0:
        return "Buzz"
    return str(x)


def convert(x: str) -> str:
    try:
        return convert_integer(int(x))
    except ValueError:
        return x


if __name__ == "__main__":
    import sys
    print("\n".join(convert(arg) for arg in sys.argv[1:]))