# {{{Init
zmodload zsh/zprof  # zprof | vimpager
export PATH="$HOME/node_modules/.bin:$HOME/.local/bin:$HOME/.local/share/bin:$PATH"
export TERM=xterm-256color
export HISTFILE="$HOME/.zsh_history"
export HISTSIZE=999999999
export SAVEHIST=$HISTSIZE
if [[ $(ps -o comm= -p $(($(ps -o ppid= -p $(($(ps -o sid= -p $$))))))) != *"tmux"* ]]; then
    export TERM_Emulator=$(ps -o comm= -p $(($(ps -o ppid= -p $(($(ps -o sid= -p $$)))))))
fi
export EDITOR=nvim
export BROWSER="chromium"
export PAGER="nvim --cmd 'let g:VIM_MANPAGER = 1' -c MANPAGER -"
export MANPAGER="nvim --cmd 'let g:VIM_MANPAGER = 1' -c MANPAGER -"
export FuzzyFinder="fzf"
# {{{rtv
export RTV_EDITOR="nvim"
export RTV_BROWSER="w3m"
export RTV_URLVIEWER="urlscan"
# }}}
# }}}
# {{{Functions
test_cmd_pre() { # {{{
    command -v "$1" >/dev/null
} # }}}
test_cmd() { # {{{
    test_cmd_pre "$1" && echo 'yes' || echo 'no'
} # }}}
switch_tmuxline() { # {{{
    echo ""
    ls ~/.tmux/tmuxline/ | sed 's/\..*//g'
    echo ""
    read -r TMUXLINE_COLOR_SCHEME
    while [ "$TMUXLINE_COLOR_SCHEME"x != "q"x ]; do
        if [[ "$TMUXLINE_COLOR_SCHEME" == "disable" ]]; then
            echo ""
            echo 'export TMUXLINE_COLOR_SCHEME="disable"'
        else
            tmux source-file "$HOME/.tmux/tmuxline/$TMUXLINE_COLOR_SCHEME.tmux.conf"
            tmux source-file "$HOME/.tmux.conf"
        fi
        echo ""
        ls ~/.tmux/tmuxline/ | sed 's/\..*//g'
        echo ""
        read -r TMUXLINE_COLOR_SCHEME
    done
} # }}}
# {{{FuzzyFinder
# fuzzy match dirs and cd
cdf() {
    local dir
    dir=$(find ${1:-.} -path '*/\.*' -prune \
        -o -type d -print 2> /dev/null | "$FuzzyFinder") &&
        cd "$dir"
    }
# include hidden dirs
cdf_all() {
    local dir
    dir=$(find ${1:-.} -type d 2> /dev/null | grep -v ".git/" | "$FuzzyFinder") && cd "$dir"
}
# job to fore
job_fore() {
    JOB_ID=$(jobs | grep "[[[:digit:]]*]" | "$FuzzyFinder" | grep -o "[[[:digit:]]*]" | grep -o "[[:digit:]]*")
    fg %"$JOB_ID"
}

# job to back
job_back() {
    JOB_ID=$(jobs | grep "[[[:digit:]]*]" | "$FuzzyFinder" | grep -o "[[[:digit:]]*]" | grep -o "[[:digit:]]*")
    bg %"$JOB_ID"
}

# job kill
job_kill() {
    JOB_ID=$(jobs | grep "[[[:digit:]]*]" | "$FuzzyFinder" | grep -o "[[[:digit:]]*]" | grep -o "[[:digit:]]*")
    kill %"$JOB_ID"
}

# proc ls
proc_ls() {
    PROC_ID_ORIGIN=$(ps -alf | "$FuzzyFinder")
    if [[ $(echo "$PROC_ID_ORIGIN" | grep "UID[[:blank:]]*PID")x == ""x ]]; then
        PROC_ID=$(echo "$PROC_ID_ORIGIN" | grep -o '^[^[:blank:]]*[[:blank:]]*[^[:blank:]]*[[:blank:]]*[^[:blank:]]*[[:blank:]]*[^[:blank:]]*' | grep -o '[[:digit:]]*$')
        echo "$PROC_ID_ORIGIN"
    fi
}

# proc ls all
proc_ls_all() {
    PROC_ID_ORIGIN=$(ps -elf | "$FuzzyFinder")
    if [[ $(echo "$PROC_ID_ORIGIN" | grep "UID[[:blank:]]*PID")x == ""x ]]; then
        PROC_ID=$(echo "$PROC_ID_ORIGIN" | grep -o '^[^[:blank:]]*[[:blank:]]*[^[:blank:]]*[[:blank:]]*[^[:blank:]]*[[:blank:]]*[^[:blank:]]*' | grep -o '[[:digit:]]*$')
        echo "$PROC_ID_ORIGIN"
    fi
}

# proc info
proc_info() {
    PROC_ID_ORIGIN=$(ps -alf | "$FuzzyFinder")
    if [[ $(echo "$PROC_ID_ORIGIN" | grep "UID[[:blank:]]*PID")x == ""x ]]; then
        PROC_ID=$(echo "$PROC_ID_ORIGIN" | grep -o '^[^[:blank:]]*[[:blank:]]*[^[:blank:]]*[[:blank:]]*[^[:blank:]]*[[:blank:]]*[^[:blank:]]*' | grep -o '[[:digit:]]*$')
        top -p "$PROC_ID"
    fi
}

# proc info all
proc_info_all() {
    PROC_ID_ORIGIN=$(ps -elf | "$FuzzyFinder")
    if [[ $(echo "$PROC_ID_ORIGIN" | grep "UID[[:blank:]]*PID")x == ""x ]]; then
        PROC_ID=$(echo "$PROC_ID_ORIGIN" | grep -o '^[^[:blank:]]*[[:blank:]]*[^[:blank:]]*[[:blank:]]*[^[:blank:]]*[[:blank:]]*[^[:blank:]]*' | grep -o '[[:digit:]]*$')
        top -p "$PROC_ID"
    fi
}

# proc tree
proc_tree() {
    PROC_ID_ORIGIN=$(ps -alf | "$FuzzyFinder")
    if [[ $(echo "$PROC_ID_ORIGIN" | grep "UID[[:blank:]]*PID")x == ""x ]]; then
        PROC_ID=$(echo "$PROC_ID_ORIGIN" | grep -o '^[^[:blank:]]*[[:blank:]]*[^[:blank:]]*[[:blank:]]*[^[:blank:]]*[[:blank:]]*[^[:blank:]]*' | grep -o '[[:digit:]]*$')
        pstree -p "$PROC_ID"
    fi
}

# proc tree all
proc_tree_all() {
    PROC_ID_ORIGIN=$(ps -elf | "$FuzzyFinder")
    if [[ $(echo "$PROC_ID_ORIGIN" | grep "UID[[:blank:]]*PID")x == ""x ]]; then
        PROC_ID=$(echo "$PROC_ID_ORIGIN" | grep -o '^[^[:blank:]]*[[:blank:]]*[^[:blank:]]*[[:blank:]]*[^[:blank:]]*[[:blank:]]*[^[:blank:]]*' | grep -o '[[:digit:]]*$')
        pstree -p "$PROC_ID"
    fi
}

# proc kill
proc_kill() {
    PROC_ID_ORIGIN=$(ps -alf | "$FuzzyFinder")
    if [[ $(echo "$PROC_ID_ORIGIN" | grep "UID[[:blank:]]*PID")x == ""x ]]; then
        PROC_ID=$(echo "$PROC_ID_ORIGIN" | grep -o '^[^[:blank:]]*[[:blank:]]*[^[:blank:]]*[[:blank:]]*[^[:blank:]]*[[:blank:]]*[^[:blank:]]*' | grep -o '[[:digit:]]*$')
        kill -9 "$PROC_ID"
    fi
}

# proc kill
proc_kill_all() {
    PROC_ID_ORIGIN=$(ps -elf | "$FuzzyFinder")
    if [[ $(echo "$PROC_ID_ORIGIN" | grep "UID[[:blank:]]*PID")x == ""x ]]; then
        PROC_ID=$(echo "$PROC_ID_ORIGIN" | grep -o '^[^[:blank:]]*[[:blank:]]*[^[:blank:]]*[[:blank:]]*[^[:blank:]]*[[:blank:]]*[^[:blank:]]*' | grep -o '[[:digit:]]*$')
        kill -9 "$PROC_ID"
    fi
}
# }}}
# {{{comp_gen
comp_gen () {
    echo "[1] manpage  [2] help"
    read -r var
    if [[ "$var"x == "1"x ]]; then
        find -L /usr/share/man -type f -print -o -type l \
            -print -o  \( -path '*/\.*' -o -fstype 'devfs' -o -fstype 'devtmpfs' -o -fstype 'proc' \) \
            -prune 2> /dev/null |\
            sed 's|\./||g' |\
            fzf |\
            xargs -i sh ~/.zplugin/plugins/nevesnunes---sh-manpage-completions/gencomp-manpage {}
    elif [[ "$var"x == "2"x ]]; then
        TARGET=$(compgen -cb | fzf)
        gencomp "$TARGET"
    fi
    zpcompinit
}
# }}}
# }}}
# {{{Settings
# {{{general
set -o monitor
set +o nonotify
umask 077
setopt HIST_IGNORE_DUPS                         # eliminate duplicate entries in history
setopt correctall                               # enable auto correction
setopt autopushd pushdignoredups                # auto push dir into stack and and don’t duplicate them
# }}}
# {{{prompt
autoload -U promptinit
promptinit
# }}}
# {{{completion
zcomp_init () {
    autoload -U +X compinit && compinit
    autoload -U +X bashcompinit && bashcompinit
    zstyle ':completion:*' menu select                                      # use arrow key for completion
    zstyle ':completion::complete:*' gain-privileges 1                      # enabling autocompletion of privileged environments in privileged commands
    zstyle ':completion:*' rehash true                                      # auto rehash new command
    zstyle ':completion:*:descriptions' format '%U%B%d%b%u'                 # beautify completion style
    zstyle ':completion:*:warnings' format '%BSorry, no matches for: %d%b'  # beautify completion style
    zstyle ':completion:*' completer _complete _match _approximate          # fuzzy match completions
    zstyle ':completion:*:match:*' original only                            # fuzzy match completions
    zstyle ':completion:*:approximate:*' max-errors 1 numeric               # fuzzy match completions
    zstyle -e ':completion:*:default' list-colors 'reply=("${PREFIX:+=(#bi)($PREFIX:t)*==34=34}:${(s.:.)LS_COLORS}")';      #highlight prefix
    setopt menu_complete                                                    # press <Tab> once to select item
    setopt COMPLETE_ALIASES                                                 # complete alias
}
# }}}
# }}}
# {{{Alias
alias ls='lsd'
alias ls-rec='lsd --tree'
alias ls-all='/usr/bin/ls --color=auto -F -ilsh'
alias fzy="fzy --lines=15 --prompt='➤ '"
alias du='du -hc'
alias df='df -h'
alias cp='cp -ip'
alias mv='mv -i'
alias cdf-all='cdf_all'
alias cdh='pushd +$( dirs -v | "$FuzzyFinder" | grep -o "[[:digit:]]") > /dev/null'
alias cdh-ls='dirs -vl | "$FuzzyFinder"'
alias cdh-clean='popd +$( dirs -v | "$FuzzyFinder" | grep -o "[[:digit:]]") > /dev/null'
alias cdh-clean-all='dirs -c'
alias cdr='cd $(git rev-parse --show-toplevel)'
alias ps-ls='proc_ls'
alias ps-ls-all='proc_ls_all'
alias ps-info='proc_info'
alias ps-info-all='proc_info_all'
alias ps-tree='proc_tree'
alias ps-tree-all='proc_tree_all'
alias ps-kill='proc_kill'
alias ps-kill-all='proc_kill_all'
alias job-='fg %-'
alias job-ls='jobs -l'
alias job-fore='job_fore'
alias job-back='job_back'
alias job-kill='job_kill'
alias nnn='PAGER= nnn'
alias vimpager="nvim --cmd 'let g:VIM_MANPAGER = 1' -c MANPAGER -"
alias help='bash ~/repo/scripts/func/help.sh'
alias GCT='bash ~/repo/scripts/func/GCT.sh'
alias KCT='kcmcolorfulhelper -s -p'
alias tmux='tmux -2'
alias tmux-start='tmux_start'
alias haxor-news='proxychains -q haxor-news'
alias gitsome='proxychains -q gitsome'
alias rtv='proxychains -q rtv'
alias hn='proxychains -q hn'
alias git-proxy='bash ~/repo/scripts/func/git-proxy.sh'
alias bebusy='python ~/repo/scripts/func/bebusy.py'
alias clean='bash ~/repo/scripts/func/clean.sh'
alias switch_v2ray='bash ~/repo/scripts/func/v2ray/v2ray_switch.sh'
alias roll-all='bash ~/repo/scripts/func/roll.sh all'
alias roll-aur='bash ~/repo/scripts/func/roll.sh'
alias zip-r='bash ~/repo/scripts/func/zip.sh'
alias dtop='gotop -b -c vice'
alias ltop='gotop -b -c monokai'
alias browsh-docker='docker run --rm -it browsh/browsh'
alias net-test="bash ~/repo/scripts/func/net-test.sh"
alias t='goldendict'
alias gencomp-help='gencomp'
alias comp-gen='comp_gen'
if [[ "$TERM_Emulator" == "tilda" ]]; then
    alias g='BROWSER=w3m proxychains -q googler -x -n 2 -N -c us -l en --color nJmkxy'
    alias d='BROWSER=w3m proxychains -q ddgr -n 2 -x --unsafe --color mJklxy'
else
    alias g='BROWSER=w3m proxychains -q googler -x -n 7 -N -c us -l en --color nJmkxy'
    alias d='BROWSER=w3m proxychains -q ddgr -n 7 -x --unsafe --color mJklxy'
fi
# }}}
# {{{Plugins
# https://github.com/zdharma/zplugin
# https://github.com/robbyrussell/oh-my-zsh/wiki/Plugins-Overview
# https://github.com/sorin-ionescu/prezto
source ~/.zplugin/bin/zplugin.zsh
autoload -Uz _zplugin
(( ${+_comps} )) && _comps[zplugin]=_zplugin
zplugin light romkatv/powerlevel10k
zplugin light zdharma/fast-syntax-highlighting
zplugin light zsh-users/zsh-autosuggestions
zplugin ice lucid wait"0"; zplugin light zsh-users/zsh-history-substring-search
zplugin ice lucid wait"0"; zplugin light skywind3000/z.lua
zplugin ice lucid wait"1"; zplugin light ytet5uy4/fzf-widgets
zplugin ice lucid wait"0"; zplugin light urbainvaes/fzf-marks
zplugin ice lucid wait"1"; zplugin light hlissner/zsh-autopair
zplugin ice lucid wait"1"; zplugin light peterhurford/git-it-on.zsh
zplugin ice lucid wait"0"; zplugin snippet OMZ::lib/functions.zsh
zplugin ice lucid wait"1"; zplugin snippet OMZ::plugins/vi-mode/vi-mode.plugin.zsh
zplugin ice lucid wait"1"; zplugin snippet OMZ::plugins/command-not-found/command-not-found.plugin.zsh
zplugin ice lucid wait"1"; zplugin snippet OMZ::plugins/extract/extract.plugin.zsh
zplugin ice lucid wait"1"; zplugin snippet OMZ::plugins/web-search/web-search.plugin.zsh
zplugin ice lucid wait"1"; zplugin snippet OMZ::plugins/frontend-search/frontend-search.plugin.zsh
zplugin ice lucid wait"0" blockf; zplugin light zsh-users/zsh-completions
zplugin ice lucid wait"0" blockf svn; zplugin snippet https://github.com/zchee/zsh-completions/trunk/src/zsh
zplugin ice lucid wait"0" blockf; zplugin light ryutok/rust-zsh-completions
zplugin ice lucid wait"0"; zplugin light RobSis/zsh-completion-generator
zplugin ice lucid wait"0" atload"export FPATH=$HOME/.zplugin/plugins/RobSis---zsh-completion-generator/completions:$HOME/.zplugin/plugins/nevesnunes---sh-manpage-completions/completions/zsh:$FPATH; zcomp_init" as"program" atclone"mv run.sh gencomp-manpage; sed -i -e '1i pushd ~/.zplugin/plugins/nevesnunes---sh-manpage-completions/' -e '\$a popd' gencomp-manpage" pick"run.sh"; zplugin light nevesnunes/sh-manpage-completions
source "$HOME/.zsh-theme"
# {{{fzf
export FZF_DEFAULT_COMMAND='fd --type f'
export FZF_DEFAULT_OPTS="
-m --height=50%
--layout=reverse
--prompt='➤ '
--ansi
--tabstop=4
--color=dark
--color=fg:#a0a1a7,bg:-1,hl:#61afef,fg+:#61afef,bg+:-1,hl+:#d858fe
--color=info:#c678dd,prompt:#c678dd,pointer:#98c379,marker:#98c379,spinner:#61afef,header:#98c379
"
source /usr/share/fzf/completion.zsh  # 模糊匹配路径，**<Tab>触发
bindkey '^F'  fzf-select-widget
# }}}
# {{{fzf-marks
# Usage: mark fzm C-d
FZF_MARKS_FILE="$HOME/.cache/fzf-marks"
FZF_MARKS_COMMAND="fzf"
FZF_MARKS_COLOR_RHS="249"
# }}}
# {{{zsh-autosuggestions
export ZSH_AUTOSUGGEST_USE_ASYNC="true"
export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=244"
bindkey '^[^M' autosuggest-execute
# }}}
# {{{zsh-history-substring-search
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey -M vicmd 'k' history-substring-search-up
bindkey -M vicmd 'j' history-substring-search-down
# }}}
# {{{z.lua
export _ZL_DATA="$HOME/.cache/.zlua"
export _ZL_MATCH_MODE=1
alias zc='z -c' # 严格匹配当前路径的子路径
alias zz='z -i' # 使用交互式选择模式
alias zf='z -I' # 使用 fzf 对多个结果进行选择
# }}}
# {{{zsh-completion-generator
# gencomp fzf
# gencomp fzy
# gencomp firefox-developer-edition
# gencomp gotop
# gencomp browsh
# gencomp pip
# }}}
# }}}
# {{{TMUX
# {{{TMUX Start
tmux_start() {
    alias tmux='tmux -2'
    if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
        git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
    fi
    nvim_exist=$(test_cmd nvim)
    if [[ "$TERM_Emulator" != "tilda" ]]; then
        if [[ -z "$TMUX" ]]; then
            ID="$(tmux ls | grep -vm1 attached | grep Alpha | cut -d: -f1)" # check if Alpha session exist
            if [[ -z "$ID" ]]; then # if not, creat a new one
                tmux new-session -d -s Alpha
                tmux source-file "$HOME/.tmux/tmuxline/$TMUXLINE_COLOR_SCHEME.tmux.conf"
                tmux new-window -t Alpha
                # tmux send-keys -t Alpha:0 "cd ~" Enter
                if [[ "$nvim_exist" == "yes" ]]; then
                    tmux send-keys -t Alpha:0 "export TERM_Emulator=$TERM_Emulator" Enter
                    tmux send-keys -t Alpha:0 "nvim" Enter
                elif [[ "$nvim_exist" == "no" ]]; then
                    tmux send-keys -t Alpha:0 "export TERM_Emulator=$TERM_Emulator" Enter
                    tmux send-keys -t Alpha:0 "vim" Enter
                fi
                tmux attach -t Alpha:1
            else
                tmux attach-session -t Alpha # if available attach to it # else, attach it
            fi
        fi
    elif [[ "$TERM_Emulator" == "tilda" ]]; then
        if [[ -z "$TMUX" ]]; then
            ID="$(tmux ls | grep -vm1 attached | grep Beta | cut -d: -f1)" # check if Beta session exist
            if [[ -z "$ID" ]]; then # if not, creat a new one
                tmux new-session -d -s Beta
                tmux source-file "$HOME/.tmux/tmuxline/$TMUXLINE_COLOR_SCHEME.tmux.conf"
                tmux new-window -t Beta
                # tmux send-keys -t Beta:0 "cd ~" Enter
                if [[ "$nvim_exist" == "yes" ]]; then
                    tmux send-keys -t Beta:0 "nvim" Enter
                elif [[ "$nvim_exist" == "no" ]]; then
                    tmux send-keys -t Beta:0 "vim" Enter
                fi
                tmux attach -t Beta:1
            else
                tmux attach-session -t Beta # if available attach to it # else, attach it
            fi
        fi
    fi
    ~/.tmux-bind.sh no
    tmux source "$HOME/.tmux.conf"
}
# if [[ "$TERM_Emulator" == "tilda" ]]; then
# fi
# }}}
# {{{relax
relax () {
    tmux new-session -d -s Alt -c "$HOME" -n "github"
    tmux send-keys -t Alt:0 "gitsome" Enter
    tmux new-window -t Alt:1 -n "hackernews"
    tmux send-keys -t Alt:1 "haxor-news" Enter
    tmux new-window -t Alt:2 -n "reddit"
    tmux send-keys -t Alt:2 "rtv" Enter
}
# }}}
nvim_exist=$(test_cmd nvim)
if [[ "$TERM_Emulator" == "tilda" ]]; then
    tmux_start
fi
~/.tmux-bind.sh no
# }}}
