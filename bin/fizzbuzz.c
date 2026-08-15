//usr/bin/env true; cc -O2 -o /tmp/fizzbuzz_bin "$0" && exec /tmp/fizzbuzz_bin "$@"; exit

#include <stdio.h>
#include <stdlib.h>

const char *convert_integer(int x, char *buf) {
    if (x % 15 == 0) return "FizzBuzz";
    if (x % 3 == 0)  return "Fizz";
    if (x % 5 == 0)  return "Buzz";
    sprintf(buf, "%d", x);
    return buf;
}

const char *convert(const char *x, char *buf) {
    char *end;
    long n = strtol(x, &end, 10);
    if (*end == '\0' && end != x) {
        return convert_integer((int)n, buf);
    }
    return x;
}

int main(int argc, char *argv[]) {
    char buf[32];
    for (int i = 1; i < argc; i++) {
        printf("%s\n", convert(argv[i], buf));
    }
    return 0;
}