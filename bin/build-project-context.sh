#!/bin/bash
set -e

command -v gh >/dev/null 2>&1 || { echo "gh CLI required" >&2; exit 1; }
command -v jq >/dev/null 2>&1 || { echo "jq required" >&2; exit 1; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPOS_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

REPOS=$(gh repo list --source --no-archived --visibility=public --limit 1000 --json name | \
    jq -r 'sort_by(.name | ascii_downcase) | .[].name')

if [ -z "$REPOS" ]; then
    exit 0
fi

cat << EOF
# Personal Projects

Generated from \`bin/build-project-context\` on $(date '+%Y-%m-%d %H:%M:%S').

EOF

while read -r REPO_NAME; do
    REPO_PATH="$REPOS_DIR/$REPO_NAME"

    if [ ! -d "$REPO_PATH" ]; then
        continue
    fi

    README_FILE=""
    for filename in README.md README.MD Readme.md readme.md README README.txt; do
        if [ -f "$REPO_PATH/$filename" ]; then
            README_FILE="$REPO_PATH/$filename"
            break
        fi
    done

    if [ -n "$README_FILE" ]; then
        sed 's/^#/##/g' "$README_FILE"
    else
        echo "## $REPO_NAME"
        echo "*No README found*"
        echo ""
    fi
done <<< "$REPOS"
