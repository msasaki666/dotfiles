#!/usr/bin/env bash

# https://qiita.com/youcune/items/fcfb4ad3d7c1edf9dc96
set -ue
# 「function」は省略可能
link_to_homedir() {
  # commandは、シェルコマンド以外も実行できる。bulitinコマンドはシェルコマンドしか実行できない。
  command echo "backup old dotfiles..."
  # バックアップ用ディレクトリの作成
  local backupdirname=".dotbackup"
  if [ ! -d "$HOME/$backupdirname" ];then
    # ~と$HOMEは、同じ場所を示すが、""で囲んでも意味を成すのは$HOME
    command echo "$HOME/$backupdirname not found. making it."
    command mkdir "$HOME/$backupdirname"
  fi

  # dirnameは、パスからディレクトリ部分のみを取り出す
  # BASH_SOURCE[0]には実行したスクリプトのパスが入っている
  local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
  local dotdir=$script_dir
  if [[ "$HOME" != "$dotdir" ]];then
    # ?: 任意の一文字にマッチ
    # *: 長さ0以上の文字列にマッチ
    for f in "$dotdir"/.??* "$dotdir"/Taskfile.base.yml; do
      local filename=$(basename $f)
      # -L: ファイルが存在し、シンボリックリンクであれば真
      if [[ -L "$HOME/$filename" ]];then
        command rm -f "$HOME/$filename"
      fi
      if [[ -e "$HOME/$filename" ]];then
        command mv "$HOME/$filename" "$HOME/$backupdirname"
      fi
      # -s: ハードリンクではなく、シンボリックリンクを作る
      # -n: リンクの作成場所として指定したディレクトリがシンボリックリンクだった場合、参照先にリンクを作るのではなく、シンボリックリンクそのものを置き換える（-fと組み合わせて使用）
      # -f: 同じ名前のファイルがあっても強制的に上書き
      command ln -snf $f $HOME
    done

    if [ ! -f "$HOME/Taskfile.yml" ];then
      echo "copying Taskfile.yml..."
      command cp "$dotdir/Taskfile.concrete.yml" "$HOME/Taskfile.yml"
    fi
  else
    command echo "home directory is same as install src"
  fi
}


update_preference() {
  if [[ "$SHELL" == "/bin/bash" ]];then
    command source "$HOME/.bashrc"
  elif [[ "$SHELL" == "/bin/zsh" ]];then
    command zsh -c "source $HOME/.zshrc"
  else
    command echo "unknown shell"
  fi
}

link_to_homedir
update_preference
command echo -e "\e[1;36m Install completed!!!! \e[m"
