# Fig pre block. Keep at the top of this file.
[[ -f "$HOME/.fig/shell/zshrc.pre.zsh" ]] && builtin source "$HOME/.fig/shell/zshrc.pre.zsh"


########## oh-my-zsh configuration start##########
# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git)

if [ -f $ZSH/oh-my-zsh.sh ]; then
  source $ZSH/oh-my-zsh.sh
fi

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='nvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch $(uname -m)"

# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
########## oh-my-zsh configuration end ##########


# Common aliases for Bash and Zsh
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
alias gst='git status'
alias d='docker'
alias dc='docker compose'
alias dcm='docker compose -f compose.me.yaml'
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
if [[ -o zle ]]; then
# 関数をwidgetに登録
  zle -N execute_from_peco_history
fi
# 対話シェルかつ ZLE が有効なときだけ bindkey を有効化
if [[ -o interactive ]] && [[ -o zle ]]; then
    # widgetを特定のキー入力に登録
    bindkey '^r' execute_from_peco_history
fi

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

plugins=(... direnv)
# NOTE: ウェブブラウザ内でファイルパスをクリック可能にする場合（例えば型エラーが発生した時など）、シェル環境（例：.bashrc）で以下の環境変数をエクスポートしてください：
# https://ihp.digitallyinduced.com/Guide/editors.html#using-ihp-with-visual-studio-code-vscode
export IHP_EDITOR="code --goto"
# Added by Antigravity
export PATH="/Users/motoakisasaki/.antigravity/antigravity/bin:$PATH"
