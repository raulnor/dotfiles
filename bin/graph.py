#!/usr/bin/env python3

import sys
import matplotlib.pyplot as plt

if __name__ == "__main__":
    if len(sys.argv) >= 2:
        data = sys.argv[1:]
        plt.plot(data)
        plt.show()
    else:
        print("graph.py NUMBERS")
