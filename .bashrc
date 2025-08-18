# Fig pre block. Keep at the top of this file.
[[ -f "$HOME/.fig/shell/bashrc.pre.bash" ]] && builtin source "$HOME/.fig/shell/bashrc.pre.bash"

[[ -f "$HOME/.aliases.sh" ]] && source "$HOME/.aliases.sh"
alias reload="source ~/.bashrc"


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
    SELECTED_HISTORY=$(history | $tac | peco --layout bottom-up)
    if [ "$SELECTED_HISTORY" != "" ]; then
        # 数字 command...のうち、command...を抽出
        EXTRACTED_COMMAND=$(echo $SELECTED_HISTORY | awk '{for(i=2;i<NF;i++){printf("%s%s",$i,OFS=" ")}print $NF}')
        echo $EXTRACTED_COMMAND
        eval $EXTRACTED_COMMAND
        history -s $EXTRACTED_COMMAND
    fi
}
bind -x '"\C-r": execute_from_peco_history'

# PS1のデフォルトは、\h:\W \u\$
function set_up_prompt() {
    PS1="\u@\W\[\e[1;31m\]\$\[\e[m\] "
}
set_up_prompt

# 色変更方法: https://qiita.com/wildeagle/items/5da17e007e2c284dc5dd
function apply_kube_ps1() {
    KUBE_PS1_PATH="/usr/local/opt/kube-ps1/share/kube-ps1.sh"
    if [ -e $KUBE_PS1_PATH ]; then
        source $KUBE_PS1_PATH
        PS1='$(kube_ps1)'$PS1
    fi
}
apply_kube_ps1
# for krew
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

HISTSIZE=1000
HISTFILESIZE=1000

# -w ファイルが閉じられてからreturnする
export EDITOR="code -w"

function set_bundle_editor_for_remote_container() {
    # vscode remote containerの時はbundle openの時に、code -wだとうまく動かないので
    if [ -e "$REMOTE_CONTAINERS" ]; then
        export BUNDLER_EDITOR=code
    fi
}
set_bundle_editor_for_remote_container

if which rbenv > /dev/null; then
 eval "$(rbenv init -)"
fi

export PATH="/usr/local/opt/openjdk/bin:$PATH"

if which go > /dev/null; then
    # shellcheck disable=SC2155
    export PATH="$PATH:$(go env GOPATH)/bin"
fi

# https://cloud.google.com/blog/products/containers-kubernetes/kubectl-auth-changes-in-gke
export USE_GKE_GCLOUD_AUTH_PLUGIN=True
export PATH="$PATH:/opt/metasploit-framework/bin"
export PATH="$PATH:/usr/local/lib/flutter/bin"
export GEM_HOME=$HOME/.gem
export PATH=$GEM_HOME/bin:$PATH

if which pack > /dev/null; then
    # shellcheck disable=SC1090
    . "$(pack completion)"
fi

export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"

if [ -f ~/.config/op/plugins.sh ]; then
  # shellcheck disable=SC1090
  source ~/.config/op/plugins.sh
fi

if [ -f "$HOME"/.cargo/env ]; then
  # shellcheck disable=SC1091
  . "$HOME/.cargo/env"
fi

if [ -f "$HOME"/.ghcup/env ]; then
  # shellcheck disable=SC1091
  . "$HOME/.ghcup/env"
fi

export PATH="/opt/homebrew/opt/libpq/bin:$PATH"
export PATH="/opt/homebrew/opt/curl/bin:$PATH"


if which task > /dev/null; then
    eval "$(task --completion bash)"
    alias t='task'
fi

# Added by Windsurf
export PATH="$HOME/.codeium/windsurf/bin:$PATH"

if which firefly > /dev/null; then
    alias ff='firefly'
fi

if [ -f "$HOME/.local/bin/env" ]; then
    . "$HOME/.local/bin/env"
fi

if [ -f "$HOME/config/op/plugins.sh" ]; then
    . "$HOME/.config/op/plugins.sh"
fi

export PATH="$HOME/.local/bin:$PATH"

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
