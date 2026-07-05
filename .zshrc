HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
bindkey -e

PATH="/opt/homebrew/opt/openjdk/bin:$PATH" # Java
PATH=${HOME}/.local/bin:$PATH # PIP
PATH=${HOME}/go/bin:$PATH # Go
PATH="/opt/homebrew/opt/ruby/bin:$PATH" # Ruby
PATH=${HOME}/.emacs.d/bin:$PATH # Emacs
PATH=${HOME}/Library/Android/sdk/platform-tools:$PATH # Android
PATH=${HOME}/bin:$PATH # Scripts
PATH=${HOME}/local/bin:$PATH # Small compiled programs
export ANDROID_HOME=${HOME}/Library/Android/sdk/
eval "$(~/.local/bin/mise activate)" # Mise
fpath=(~/.zfunc $fpath)
autoload -Uz compinit && compinit

function code { open -a "Visual Studio Code" $argv }
function edge { open -a "Microsoft Edge" $argv }
function safari { open -a "Safari" $argv }
function xc { open -a "Xcode" $argv }
function reload_zsh_config { source ~/.zshrc }

export CODE="${HOME}/Code"
PROMPT="%F{yellow}%T %F{cyan}%~ %F{white}%# "
RPROMPT=""

function list-projects {
    find ${CODE} -name .git -maxdepth 3 | sed s/.git$//g
}

function pick-commit {
    git log --decorate --pretty="format:%h - %an: %s" --abbrev-commit | fzf --preview 'git show --color=always --stat {1}' | awk '{print $1}'
}

function git-claim-penndotvso {
    git config --add --local user.name 'Travis Luckenbaugh'
    git config --add --local user.email 'c-tralucke@pa.gov'
    git config --add --local core.sshCommand 'ssh -i ~/.ssh/id_penndot_c_tralucke -o IdentitiesOnly=yes'
}

function git-claim-personal {
    git config --add --local user.name 'Travis Luckenbaugh'
    git config --add --local user.email 'tluckenbaugh@gmail.com'
    git config --add --local core.sshCommand 'ssh -i ~/.ssh/id_rsa -o IdentitiesOnly=yes'
}

function git-claim-subaru {
    git config --add --local user.name 'Travis Luckenbaugh'
    git config --add --local user.email 'tlucke@subaru.com'
    git config --add --local core.sshCommand 'ssh -i ~/.ssh/id_ed25519_subaru -o IdentitiesOnly=yes'
}

function pbsort {
    pbpaste | sort "$@" | pbcopy
}

services=(
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

function svc() {
  case "$1" in
    ls)
      printf "%-30s %8s %6s %6s\n" "SERVICE" "PID" "CPU" "MEM"
      for s in "${services[@]}"; do
        pid=$(launchctl list | grep "$s" | awk '{print $1}')
        if [[ "$pid" =~ ^[0-9]+$ ]]; then
          cpu=$(ps -p "$pid" -o %cpu= 2>/dev/null)
          mem=$(ps -p "$pid" -o %mem= 2>/dev/null)
          printf "%-30s %8s %6s %6s\n" "$s" "$pid" "$cpu" "$mem"
        else
          printf "%-30s %8s\n" "$s" "-"
        fi
      done
      ;;
    stop)   launchctl stop "$2" ;;
    start)  launchctl start "$2" ;;
    restart) launchctl stop "$2"; sleep 1; launchctl start "$2" ;;
    *)      echo "usage: svc [ls|start|stop|restart] [service]" ;;
  esac
}

# Run HTTP server then open browser
function up {
    PORT=$(( $RANDOM % 48576 + 16384 ))
    VIEWER=${1?open}
    python3 -m http.server ${PORT} &
    ${VIEWER} "http://localhost:${PORT}/"
    fg
}

function xman {
    open x-man-page://$1
}

# Find potentially large source code files
function bigfiles {
    fd -t f -E "*.png" -E "*.xcodeproj" | xargs wc -l | sort
}


alias lg='lazygit'
alias dictwords='cat /usr/share/dict/words | fzf'
alias wordle='cat ${HOME}/share/wordle | fzf'
alias octordle='cat ${HOME}/share/octordle | fzf'
alias skiping='ping skitheeast.asuscomm.com'

[ -f ~/.config/zsh/fzf.zsh ] && source ~/.config/zsh/fzf.zsh
[ -f ~/.config/zsh/pcd.zsh ] && source ~/.config/zsh/pcd.zsh
[ -f ~/.config/zsh/zoxide.zsh ] && source ~/.config/zsh/zoxide.zsh
export PATH="/opt/homebrew/opt/postgresql@16/bin:$PATH"
