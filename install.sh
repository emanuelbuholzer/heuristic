#!/usr/bin/env bash


# we save the directory we've been called from, get the directory of the script
# and go there. this is were we'll work.
call_dir=$(pwd)
script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
cd "$script_dir"


echo -e "\n==> installing heuristic desktop from $script_dir"
echo ; read -p "do you want to proceed: [y/N] " do_install
if [ "$do_install" != "y" ]; then
  echo "aborting"
  exit 1
fi


# ask for sudo, so we don't need to later :-)
echo 
sudo echo


# check for updates and offer graceful reboot because we need a fresh system
echo -e "==> checking for updates"
sudo dnf update
sudo dnf upgrade --refresh

echo ; read -p "do you need to reboot: [y/N] " do_reboot
if [ "$do_reboot" == "y" ]; then
  echo "aborting install to reboot"
  sleep 5
  sudo poweroff --reboot
fi


# mark where heuristic has been installed from
echo "$script_dir" > ~/.heuristic


# basic packages
echo -e "\n==> installing basic packages"
sudo dnf install -y \
  git \
  git-lfs \
  ShellCheck \
  vim \
  kitty \
  flatpak \
  rofi \
  arandr \
  light \
  distrobox \
  podman \
  buildah \
  virt-viewer \
  virt-manager \
  lorax \
  pykickstart


# 1password
echo -e "\n==> installing 1password"
sudo rpm --import https://downloads.1password.com/linux/keys/1password.asc
sudo sh -c 'echo -e "[1password]\nname=1Password Stable Channel\nbaseurl=https://downloads.1password.com/linux/rpm/stable/\$basearch\nenabled=1\ngpgcheck=1\nrepo_gpgcheck=1\ngpgkey=\"https://downloads.1password.com/linux/keys/1password.asc\"" > /etc/yum.repos.d/1password.repo'
sudo dnf check-update -y 1password-cli 1password && sudo dnf install -y 1password-cli 1password
mkdir ~/.ssh
cat <<EOF > ~/.ssh/config
Host *
	IdentityAgent ~/.1password/agent.sock
EOF


# tailscale
echo -e "\n==> installing tailscale"
sudo dnf config-manager --add-repo https://pkgs.tailscale.com/stable/fedora//tailscale.repo
sudo dnf install -y tailscale
sudo systemctl enable --now tailscaled


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
for dotfile in $(find $(pwd) -maxdepth 1 -name ".*" -not -name ".gitignore" -not -name ".git" -not -name ".*.swp"); do
  filename=$(basename $dotfile)
  echo "installing dotfile $filename"
  ln -snf "$dotfile" "$HOME/$filename"
done
unset dotfile


# fira code
echo -e "\n==> installing fonts"
sudo dnf install -y fira-code-fonts
fc-cache -rf


# setup flatpak and some basic apps
echo -e "\n==> installing flatpak and basic apps"
flatpak remote-add --user --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

flatpak install --user -y flathub org.gnome.Firmware
flatpak install --user -y flathub com.google.Chrome

flatpak install --user -y flathub org.gnome.font-viewer
flatpak install --user -y flathub com.github.tchx84.Flatseal
# for the gtk th--user eming
flatpak install --user -y flathub com.github.themix_project.Oomox
flatpak install --user -y flathub us.zoom.Zoom
flatpak install --user -y flathub com.github.IsmaelMartinez.teams_for_linux

flatpak install --user -y flathub org.wireshark.Wireshark
flatpak install --user -y flathub org.gnome.Evince
flatpak install --user -y flathub org.libreoffice.LibreOffice
flatpak install --user -y flathub io.dbeaver.DBeaverCommunity
flatpak install --user -y flathub org.remmina.Remmina
flatpak install --user -y flathub org.ksnip.ksnip


# cleanup
echo -e "\n==> cleaning up"
rm -r \
	~/Desktop \
	~/Downloads \
	~/Templates \
	~/Public \
	~/Documents \
	~/Music \
	~/Pictures \
	~/Videos 

sudo dnf remove -y \
  firefox


# after we get a new X session, mosth things should be applied
echo -e "\n==> installation complete"
echo ; read -p "do you want to to exit i3 to apply most changes: [y/N] " do_exit_i3
if [ "$do_exit_i3" == "y" ]; then
	i3-msg exit
fi
