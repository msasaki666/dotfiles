#!/usr/bin/env bash

# https://qiita.com/youcune/items/fcfb4ad3d7c1edf9dc96
set -ue

link_to_homedir() {
  # commandは、シェルコマンド以外も実行できる。bulitinコマンドはシェルコマンドしか実行できない。
  command echo "backup old dotfiles..."
  # バックアップ用ディレクトリの作成
  local backupdirname=".dotbackup"
  if [ ! -d "$HOME/$backupdirname" ];then
    # ~と$HOMEは、同じ場所を示すが、""で囲んでも意味を成すのは$HOME
    command echo "$HOME/$backupdirname not found. Auto Make it"
    command mkdir "$HOME/$backupdirname"
  fi

  # dirnameは、パスからディレクトリ部分のみを取り出す
  # BASH_SOURCE[0]には実行したスクリプトのパスが入っている
  local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
  local dotdir=$(dirname ${script_dir})
  if [[ "$HOME" != "$dotdir" ]];then
    # ?: 任意の一文字にマッチ
    # *: 長さ0以上の文字列にマッチ
    for f in $dotdir/.*; do
      local filename=`basename $f`
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
  else
    command echo "same install src dest"
  fi
}


link_to_homedir
command echo -e "\e[1;36m Install completed!!!! \e[m"
