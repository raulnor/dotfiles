#!/usr/bin/python

import fileinput

def snake_to_lower_camel(input):
    items = line.strip().split("_")
    if len(items) == 0: return ""
    if len(items) == 1: return items[0]
    return "".join([items[0].lower()] + [x.capitalize() for x in items[1:]])

for line in fileinput.input():
    output = snake_to_lower_camel(line.rstrip())
    print(output)
    
    