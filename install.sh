#!/usr/bin/env bash

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
cd "$script_dir"

echo -e "\n==> installing heuristic desktop from $script_dir"
echo ; read -p "do you want to proceed: [y/N] " do_install
if [ "$do_install" != "y" ]; then
  echo "aborting"
  exit 1
fi

echo 
sudo echo

echo -e "==> checking for updates"
sudo dnf update
echo ; read -p "do you need to reboot: [y/N] " do_reboot
if [ "$do_reboot" == "y" ]; then
  sudo poweroff --reboot
fi


# goodies
echo "$script_dir" > ~/.heuristic
xrandr -s 1920x1080


# basic packages
echo -e "\n==> installing basic packages"
sudo dnf install -y \
  git \
  vim \
  kitty \
  flatpak \
  rofi \
  virt-viewer

# 1password
echo -e "\n==> installing 1password"
sudo rpm --import https://downloads.1password.com/linux/keys/1password.asc
sudo sh -c 'echo -e "[1password]\nname=1Password Stable Channel\nbaseurl=https://downloads.1password.com/linux/rpm/stable/\$basearch\nenabled=1\ngpgcheck=1\nrepo_gpgcheck=1\ngpgkey=\"https://downloads.1password.com/linux/keys/1password.asc\"" > /etc/yum.repos.d/1password.repo'
sudo dnf check-update -y 1password && sudo dnf install -y 1password
cat <<EOF > ~/.ssh/config
Host *
	IdentityAgent ~/.1password/agent.sock
EOF


# etc files
echo -e "\n==> installing etc files"
for localfile in $(find $(pwd)/etc -type f -not -name ".*.swp"); do
	etcfile=$(echo "$localfile" | sed -e "s|$(pwd)||")
	sudo mkdir -p $(dirname "$etcfile")
	# TODO partitioning for hardlink
	sudo cp "$localfile" "$etcfile"
done
systemctl --user daemon-reload || true
sudo systemctl daemon-reload
unset localfile
unset etcfile


# usr files
echo -e "\n==> installing usr files"
for localfile in $(find $(pwd)/usr -type f -not -name ".*.swp"); do
	usrfile=$(echo "$localfile" | sed -e "s|$(pwd)||")
	sudo mkdir -p $(dirname "$usrfile")
	# TODO partitioning for hardlink
	sudo cp "$localfile" "$usrfile"
done
unset localfile
unset usrfile


# dotfiles
echo -e "\n==> installing dotfiles"
for dotfile in $(find $(pwd) -name ".*" -not -name ".gitignore" -not -name ".git" -not -name ".*.swp"); do
  filename=$(basename $dotfile)
  echo "installing dotfile $filename"
  ln -snf "$dotfile" "$HOME/$filename"
done
unset dotfile



# fira code
echo -e "\n==> installing fonts"
mkdir -p "$HOME/.local/share"
ln -snf "$script_dir/fonts" "$HOME/.local/share/fonts"
fc-cache -rf


# setup flatpak and some basic apps
echo -e "\n==> installing flatpak and basic apps"
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

flatpak install -y flathub org.gnome.Firmware
flatpak install -y flathub com.google.Chrome

flatpak install -y flathub org.gnome.font-viewer
flatpak install -y flathub com.github.tchx84.Flatseal
flatpak install flathub com.github.themix_project.Oomox
flatpak install -y flathub us.zoom.Zoom
flatpak install -y flathub com.github.IsmaelMartinez.teams_for_linux

flatpak install -y flathub org.wireshark.Wireshark
flatpak install -y flathub org.libreoffice.LibreOffice
# flatpak install -y flathub com.jetbrains.CLion
# flatpak install -y flathub com.jetbrains.IntelliJ-IDEA-Ultimate
# flatpak install -y flathub org.mozilla.Thunderbird
# flatpak install -y flathub io.dbeaver.DBeaverCommunity
# flatpak install -y flathub org.filezillaproject.Filezilla
# flatpak install -y flathub cc.arduino.IDE2
# flatpak install -y flathub com.usebottles.bottles
# flatpak install -y flathub org.gimp.GIMP

# cleanup
# TODO: home directories
echo -e "\n==> cleaning up"
sudo dnf remove -y \
  firefox


echo -e "\n==> installation complete"
echo ; read -p "do you want to to exit i3 to apply most changes: [y/N] " do_exit_i3
if [ "$do_exit_i3" == "y" ]; then
	i3-msg exit
fi
