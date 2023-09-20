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

sudo rpm --import https://downloads.1password.com/linux/keys/1password.asc
sudo sh -c 'echo -e "[1password]\nname=1Password Stable Channel\nbaseurl=https://downloads.1password.com/linux/rpm/stable/\$basearch\nenabled=1\ngpgcheck=1\nrepo_gpgcheck=1\ngpgkey=\"https://downloads.1password.com/linux/keys/1password.asc\"" > /etc/yum.repos.d/1password.repo'
sudo dnf check-update -y 1password-cli 1password && sudo dnf install 1password-cli 1password
cat <<EOF > ~/.ssh/config
Host *
	IdentityAgent ~/.1password/agent.sock
EOF

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
mkdir -p "$HOME/.local/share"
ln -snf "$script_dir/fonts" "$HOME/.local/share/fonts"
fc-cache -rf
