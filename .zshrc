# Fig pre block. Keep at the top of this file.
[[ -f "$HOME/.fig/shell/zshrc.pre.zsh" ]] && builtin source "$HOME/.fig/shell/zshrc.pre.zsh"

alias g='git'
alias gcm='git checkout master'
alias gdf='git diff'
alias gcp='git cherry-pick'
alias gb='git branch'
alias gds='git ds'
alias gf='git fetch'
alias gg='git grep -n'
alias gmt='git mergetool'
alias gl='git lg'
alias glo='git log --oneline'
alias gc='git commit'
alias ga='git add'
alias gaa='git add .'
alias gch='git checkout'
alias grprs='t=`git describe --abbrev=0 --tags`;echo "Since $t:";echo;git log $t..origin/master --merges|grep "^    .\+"|grep -v Merge|sed -e"s/    //g"'
alias gst='git status'
alias d='docker'
alias dc='docker compose'
alias dcd='docker compose -f docker-compose.dev.yml'
alias dct='docker compose -f docker-compose.test.yml'
alias dcdc='docker compose -f docker-compose.devcontainer.yml'
alias dcu='docker compose up'
alias dcb='docker compose build'
alias dce='docker compose exec'
alias dex='docker exec -it'
alias k='kubectl'
alias rdm='bundle exec rails db:migrate'
alias rdr='bundle exec rails db:rollback'
alias b='bundle'
alias be='bundle exec'
alias ber='bundle exec rails'
alias docked='docker run --rm -it -v ${PWD}:/rails -v ruby-bundle-cache:/bundle -p 3000:3000 ghcr.io/rails/cli'
alias gore='gore -autoimport'
alias reload="source ~/.zshrc"


function execute_from_peco_history() {
    if ! which peco >/dev/null; then
        echo "pecoがインストールされていません。"
        return
    fi
    if which tac >/dev/null; then
        local tac="tac"
    else
        local tac="tail -r"
    fi
  BUFFER=`history -n 1 | eval $tac  | awk '!a[$0]++' | peco --layout bottom-up`
  CURSOR=$#BUFFER
  zle reset-prompt
}
# 関数をwidgetに登録
zle -N execute_from_peco_history
# widgetを特定のキー入力に登録
bindkey '^r' execute_from_peco_history

# PS1のデフォルトは、\h:\W \u\$
function set_up_prompt() {
    PS1="%n@%~%F{red}\$%f "
}
set_up_prompt

# 色変更方法: https://qiita.com/wildeagle/items/5da17e007e2c284dc5dd
function apply_kube_ps1() {
    local KUBE_PS1_PATHS=(
        "/usr/local/opt/kube-ps1/share/kube-ps1.sh"
        "/opt/homebrew/opt/kube-ps1/share/kube-ps1.sh"
    )
    for p in ${KUBE_PS1_PATHS[@]}
    do
        if [ -e $p ]; then
            source $p
            PS1='$(kube_ps1)'$PS1
        fi
    done
}
apply_kube_ps1
# for krew
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

# -w ファイルがå閉じられてからreturnする
export EDITOR="code -w"

set_bundle_editor_for_remote_container() {
    # vscode remote containerの時はbundle openの時に、code -wだとうまく動かないので
    if [ -e $REMOTE_CONTAINERS ]; then
        export BUNDLER_EDITOR=code
    fi
}
set_bundle_editor_for_remote_container

### Added by Zinit's installer
if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
    print -P "%F{33} %F{220}Installing %F{33}ZDHARMA-CONTINUUM%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
    command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" && \
        print -P "%F{33} %F{34}Installation successful.%f%b" || \
        print -P "%F{160} The clone has failed.%f%b"
fi

source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# Load a few important annexes, without Turbo
# (this is currently required for annexes)
zinit light-mode for \
    zdharma-continuum/zinit-annex-as-monitor \
    zdharma-continuum/zinit-annex-bin-gem-node \
    zdharma-continuum/zinit-annex-patch-dl \
    zdharma-continuum/zinit-annex-rust

### End of Zinit's installer chunk

# この記事を参考に設定を書いた
# https://amateur-engineer-blog.com/zsh-zinit/

# 予測変換
# autoload -zU predict-on
# predict-on

autoload -zU compinit
compinit

# タイポを教えてくれる
setopt correct
# 日本語ファイル名を表示可能にする
setopt print_eight_bit

HISTFILE=~/.zsh_history
export SAVEHIST=10000
# 同時に起動しているzshの間でhistoryを共有
setopt share_history
# historyに保存するときに余分なスペースを削除
setopt hist_reduce_blanks
# 同じコマンドをhistoryに残さない
setopt hist_ignore_all_dups

export LANG=ja_JP.UTF-8

# zinit ice wait lucid
# zinit light zsh-users/zsh-completions
# zinit ice wait lucid
# zinit light zsh-users/zsh-autosuggestions

# zsh-syntax-highlightingは最後に読み込む必要がある
# https://github.com/zsh-users/zsh-syntax-highlighting#why-must-zsh-syntax-highlightingzsh-be-sourced-at-the-end-of-the-zshrc-file
zinit ice wait lucid
zinit light zsh-users/zsh-syntax-highlighting

if which rbenv > /dev/null; then
 eval "$(rbenv init -)"
fi

export PATH="/usr/local/opt/openjdk/bin:$PATH"

if which go > /dev/null; then
    export PATH="$PATH:$(go env GOPATH)/bin"
fi

# https://cloud.google.com/blog/products/containers-kubernetes/kubectl-auth-changes-in-gke
export USE_GKE_GCLOUD_AUTH_PLUGIN=True
export PATH="$PATH:/opt/metasploit-framework/bin"
export PATH="$PATH:/usr/local/lib/flutter/bin"
export GEM_HOME=$HOME/.gem
export PATH=$GEM_HOME/bin:$PATH
if which pack > /dev/null; then
    . $(pack completion --shell zsh)
fi

# pnpm
# osがmacで、pnpmコマンドが存在する場合は、pnpmのパスを設定
if [[ "$OSTYPE" == "darwin"* ]]; then
    if which pnpm > /dev/null; then
        export PNPM_HOME="$HOME/Library/pnpm"
        export PATH="$PNPM_HOME:$PATH"
    fi
fi
# pnpm end

export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"

autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /opt/homebrew/bin/terraform terraform

if [ -f ~/.config/op/plugins.sh ]; then
  source ~/.config/op/plugins.sh
fi

if [ -f "$HOME"/.cargo/env ]; then
  . "$HOME/.cargo/env"
fi

if [ -f "$HOME"/.ghcup/env ]; then
  . "$HOME/.ghcup/env"
fi

export PATH="/opt/homebrew/opt/libpq/bin:$PATH"
export PATH="/opt/homebrew/opt/curl/bin:$PATH"

# The next line updates PATH for the Google Cloud SDK.
if [ -f '$HOME/google-cloud-sdk/path.zsh.inc' ]; then . '$HOME/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '$HOME/google-cloud-sdk/completion.zsh.inc' ]; then . '$HOME/google-cloud-sdk/completion.zsh.inc'; fi

if which task > /dev/null; then
    eval "$(task --completion zsh)"
    alias t='task'
fi

# Added by Windsurf
export PATH="$HOME/.codeium/windsurf/bin:$PATH"

if which firefly > /dev/null; then
    alias ff='firefly'
fi
