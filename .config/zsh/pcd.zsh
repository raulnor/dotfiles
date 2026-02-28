# `source` this in .bashrc or .zshrc. 
# `pcd` needs to be inline to access `cd`

CODE="${CODE:-$HOME/Code}"

_list_projects() {
    find "${CODE}" -name .git -maxdepth 3 -type d 2>/dev/null | sed 's/\.git$//'
}

pcd() {
    local dir
    if [[ -n "$1" ]]; then
        # pcd <arg> — find exact or unique match
        dir=$(_list_projects | grep -F "/$1/" || _list_projects | grep -F "$1")
        # If multiple matches, narrow with fzf
        local count
        count=$(echo "$dir" | grep -c .)
        if [[ "$count" -gt 1 ]]; then
            dir=$(echo "$dir" | fzf --query="$1" --select-1 --exit-0)
        else
            dir=$(echo "$dir" | head -1)
        fi
    else
        # pcd — interactive pick
        dir=$(_list_projects | fzf)
    fi

    if [[ -n "$dir" && -d "$dir" ]]; then
        cd "$dir" || return 1
    else
        echo "pcd: no match" >&2
        return 1
    fi
}

# ZSH Completions
_pcd_completions() {
    local projects
    projects=("${(@f)$(_list_projects | xargs -I{} basename {} | sort -u)}")
    compadd -a projects
}
compdef _pcd_completions pcd