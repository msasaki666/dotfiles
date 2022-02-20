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
alias dc='docker-compose'
alias dcd='docker-compose -f docker-compose.dev.yml'
alias dct='docker-compose -f docker-compose.test.yml'
alias dcu='docker-compose up'
alias dcb='docker-compose build'
alias dce='docker-compose exec'
alias dex='docker exec -it'

alias k='kubectl'

alias rdm='rails db:migrate'
alias rdr='rails db:rollback'

alias gore='gore -autoimport'

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
    KUBE_PS1_PATH="/usr/local/opt/kube-ps1/share/kube-ps1.sh"
    if [ -e $KUBE_PS1_PATH ]; then
        source $KUBE_PS1_PATH
        PS1='$(kube_ps1)'$PS1
    fi
}
apply_kube_ps1

# -w ファイルがå閉じられてからreturnする
export EDITOR="code -w"

set_bundle_editor_for_remote_container() {
    # vscode remote containerの時はbundle openの時に、code -wだとうまく動かないので
    if [ -e $REMOTE_CONTAINERS ]; then
        export BUNDLER_EDITOR=code
    fi
}
set_bundle_editor_for_remote_container
