#!/usr/bin/env bash

xrandr -s 1920x1080
feh --bg-fill https://gravitybreak.media/userart/229.png

sudo dnf install \
  git \
  vim \
  kitty \
  flatpak \
  rofi

flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

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

echo "installing fonts"
# mkdir -p "$HOME/.local/share"
# ln -snf "$script_dir/fonts" "$HOME/.local/share/fonts"
fc-cache -rf
