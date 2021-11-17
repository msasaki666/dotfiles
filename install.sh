#!/usr/bin/env bash

link_to_homedir() {
  # commandは、シェルコマンド以外も実行できる。bulitinコマンドはシェルコマンドしか実行できない。
  command echo "backup old dotfiles..."
  # バックアップ用ディレクトリの作成
  if [ ! -d "$HOME/.dotbackup" ];then
    # ~と$HOMEは、同じ場所を示すが、""で囲んでも意味を成すのは$HOME
    command echo "$HOME/.dotbackup not found. Auto Make it"
    command mkdir "$HOME/.dotbackup"
  fi

  # dirnameは、パスからディレクトリ部分のみを取り出す
  # BASH_SOURCE[0]には実行したスクリプトのパスが入っている
  local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
  local dotdir=$(dirname ${script_dir})
  if [[ "$HOME" != "$dotdir" ]];then
    for f in $dotdir/.??*; do
      [[ `basename $f` == ".git" ]] && continue
      if [[ -L "$HOME/`basename $f`" ]];then
        command rm -f "$HOME/`basename $f`"
      fi
      if [[ -e "$HOME/`basename $f`" ]];then
        command mv "$HOME/`basename $f`" "$HOME/.dotbackup"
      fi
      command ln -snf $f $HOME
    done
  else
    command echo "same install src dest"
  fi
}
