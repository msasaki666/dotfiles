# Fig pre block. Keep at the top of this file.
[[ -f "$HOME/.fig/shell/bashrc.pre.bash" ]] && builtin source "$HOME/.fig/shell/bashrc.pre.bash"
# シェル起動時に１回、実行される。
# コマンドライン上でbashと叩くと再度.bashrcが読み込まれる。（.bash_profileは読まれない）

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
alias reload="source ~/.bashrc"

function execute_from_peco_history() {
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

set_bundle_editor_for_remote_container() {
    # vscode remote containerの時はbundle openの時に、code -wだとうまく動かないので
    if [ -e $REMOTE_CONTAINERS ]; then
        export BUNDLER_EDITOR=code
    fi
}
set_bundle_editor_for_remote_container

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
    . $(pack completion)
fi

# Fig post block. Keep at the bottom of this file.
[[ -f "$HOME/.fig/shell/bashrc.post.bash" ]] && builtin source "$HOME/.fig/shell/bashrc.post.bash"
export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"

if [ -f ~/.config/op/plugins.sh ]; then
  source ~/.config/op/plugins.sh
fi

. "$HOME/.cargo/env"

export PATH="/opt/homebrew/opt/libpq/bin:$PATH"
export PATH="/opt/homebrew/opt/curl/bin:$PATH"
