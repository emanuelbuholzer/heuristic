#!/usr/bin/env bash

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
echo "installing dotfiles from $script_dir"
read -p "do you want to proceed: [y/N] " do_install
if [ "$do_install" != "y" ]; then
  echo "aborting"
  exit 1
fi

echo "$script_dir" > ~/.heuristic

for dotfile in $(find $(pwd) -name ".*" -not -name ".gitignore" -not -name ".git" -not -name ".*.swp"); do
  filename=$(basename $dotfile)
  echo "installing dotfile $filename"
  ln -snf "$dotfile" "$HOME/$filename"
done
unset dotfile
