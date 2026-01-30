#!/usr/bin/env bash
#
# colortest - Display standard terminal colors
# Inspired by https://blog.xoria.org/terminal-colors/

set -euo pipefail

declare -a COLORS=("black" "red" "green" "yellow" "blue" "magenta" "cyan" "white")
declare -a BRIGHT_COLORS=("brblack" "brred" "brgreen" "bryellow" "brblue" "brmagenta" "brcyan" "brwhite")
declare -a FG_NORMAL=(30 31 32 33 34 35 36 37)
declare -a FG_BRIGHT=(90 91 92 93 94 95 96 97)

RESET="\033[0m"
BLOCK="██"

for i in "${!COLORS[@]}"; do
    printf "\033[${FG_NORMAL[$i]}m${BLOCK}${RESET}"
    printf " %-8s(%2d) " "${COLORS[$i]}" "${FG_NORMAL[$i]}"
    printf "\033[${FG_BRIGHT[$i]}m${BLOCK}${RESET}"
    printf " %-10s(%2d) " "${BRIGHT_COLORS[$i]}" "${FG_BRIGHT[$i]}"
    echo
done
