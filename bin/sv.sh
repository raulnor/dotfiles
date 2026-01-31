#!/usr/bin/env bash
#
# Manage launchd services

set -euo pipefail

declare -a SERVICES=(
    "com.cloudflare.cloudflared"
    "com.tl.sqlitebackup"
    "com.travis.mindari.monitor"
    "com.travis.mindari.server"
    "homebrew.mxcl.seventeenlands"
    "site.melvis.green.dnd"
    "site.melvis.green.mindari"
    "site.melvis.green.msiysp"
    "site.melvis.green.wordgames"
    "site.melvis.tempo"
)

declare -a REPLS=(
    ""  # com.cloudflare.cloudflared
    ""  # com.tl.sqlitebackup
    ""  # com.travis.mindari.monitor
    ""  # com.travis.mindari.server
    ""  # homebrew.mxcl.seventeenlands
    ""  # site.melvis.green.dnd
    "cd ~/Code/raulnor/mindari && iex -S mix phx.server"  # site.melvis.green.mindari
    ""  # site.melvis.green.msiysp
    ""  # site.melvis.green.wordgames
    ""  # site.melvis.tempo
)

function usage {
    cmd=$(basename "$0")
    echo "Usage: $cmd <command> [service]"
    echo "Commands: ls, start, stop, restart"
    echo 
    echo "Install completions:"
    echo "  $cmd zshcompletion > ~/.zfunc/_$cmd && compinit"
}

if [[ $# -lt 1 ]]; then usage; exit 1; fi
case "$1" in
ls)
    printf "%-35s %8s %6s %6s\n" "SERVICE" "PID" "CPU" "MEM"
    for s in "${SERVICES[@]}"; do
        pid=$(launchctl list | grep "$s" | awk '{print $1}' || true)
        if [[ "$pid" =~ ^[0-9]+$ ]]; then
            cpu=$(ps -p "$pid" -o %cpu= 2>/dev/null || echo "-")
            mem=$(ps -p "$pid" -o %mem= 2>/dev/null || echo "-")
            printf "%-35s %8s %6s %6s\n" "$s" "$pid" "$cpu" "$mem"
        else
            printf "%-35s %8s\n" "$s" "-"
        fi
    done
    ;;
repl)
    if [[ $# -lt 2 ]]; then echo "Error: service name required"; exit 1; fi
    svc="$2"
    
    # Find index of service
    idx=-1
    for i in "${!SERVICES[@]}"; do
        if [[ "${SERVICES[$i]}" == "$svc" ]]; then
            idx=$i
            break
        fi
    done
    
    if [[ $idx -lt 0 ]]; then echo "Error: unknown service $svc"; exit 1; fi
    
    cmd="${REPLS[$idx]}"
    if [[ -z "$cmd" ]]; then echo "Error: no repl defined for $svc"; exit 1; fi
    
    echo "Stopping $svc..."
    launchctl stop "$svc"
    
    echo "Running: $cmd"
    echo "(Ctrl-C to exit)"
    eval "$cmd" || true
    
    echo "Restarting $svc..."
    launchctl start "$svc"
    ;;
stop|start|restart)
    if [[ $# -lt 2 ]]; then echo "Error: service name required"; exit 1; fi
    if [[ "$1" == "restart" ]]; then
        launchctl stop "$2"
        sleep 1
        launchctl start "$2"
    else
        launchctl "$1" "$2"
    fi
    ;;
zshcompletion)
    cat <<EOF
#compdef service

_service() {
  local services=(
$(printf '    "%s"\n' "${SERVICES[@]}")
  )
  
  _arguments \\
    '1:command:(ls start stop restart zshcompletion)' \\
    '2:service:(\$services)'
}

_service "\$@"
EOF
  ;;
*)
    usage
    ;;
esac