#!/bin/bash

case "$1" in
  coding)
    cat <<'EOF'
# Coding

This is the Claude project where I workshop various ideas. What follows is a list of project descriptions.

EOF
    for f in \
      ~/Code/raulnor/dotfiles/README.md \
      ~/Code/raulnor/tempo/README.md \
      ~/Code/raulnor/tempo-ios/README.md 
    do
      cat "$f"
      echo
    done
    ;;
  *)
    echo "Usage: ctx <project>"
    echo ""
    echo "Projects:"
    echo "  coding    Tempo and related workshop projects"
    ;;
esac