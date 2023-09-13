
heuristic_dir=$(cat ~/.heuristic)
export XDG_CONFIG_HOME="$heuristic_dir/config"

export INPUTRC="$XDG_CONFIG_HOME"/readline/inputrc

# load .bashrc which loads does most of the heavy lifting
if [[ -r "${HOME}/.bashrc" ]]; then
  source "${HOME}/.bashrc"
fi
