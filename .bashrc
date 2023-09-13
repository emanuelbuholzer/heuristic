
# if not running interactively, don't do anything
case $- in
	*i*) ;;
	*) return ;;
esac


# check and if necessary update window size after each command
shopt -s checkwinsize

# case-insensitive globbing (used in pathname expansion)
shopt -s nocaseglob

# append to the Bash history file, rather than overwriting it
shopt -s histappend

# autocorrect typos in path names when using `cd`
shopt -s cdspell

# `autocd`, e.g. `**/qux` will enter `./foo/bar/baz/qux` (only bash 4)
shopt -s autocd

# recursive globbing, e.g. `echo **/*.txt` (only bash 4)
shopt -s globstar


# enable completion
if ! shopt -oq posix; then
	if [[ -f /usr/share/bash-completion/bash_completion ]]; then
		. /usr/share/bash-completion/bash_completion
	elif [[ -f /etc/bash_completion ]]; then
		. /etc/bash_completion
	elif [[ -f /usr/local/etc/bash_completion ]]; then
		. /usr/local/etc/bash_completion
	fi
	if [[ -d /etc/bash_completion.d/ ]]; then
		for file in /etc/bash_completion.d/* ; do
			source "$file"
		done
		unset file
	fi
fi


# set prompt
prompt_git() {
	local s='';
	local branchName='';

	# check if the current directory is in a Git repository.
	if [ "$(git rev-parse --is-inside-work-tree &>/dev/null; echo "${?}")" == '0' ]; then

		# get the short symbolic ref.
		# if HEAD isn’t a symbolic ref, get the short SHA for the latest commit
		# otherwise, just give up.
		branchName="$(git symbolic-ref --quiet --short HEAD 2> /dev/null || \
			git rev-parse --short HEAD 2> /dev/null || \
			echo '(unknown)')";

		[ -n "${s}" ] && s=" [${s}]";

		echo -e "${1}${branchName}${s}";
	else
		return;
	fi;
}

PS1="\\n\\u at \\h in \\w\$(prompt_git \" on \")\\n$ "



# load aliases
aliases_file="$HOME/.aliases"
if [[ -r $aliases_file ]] && [[ -f $aliases_file ]]; then
	source $aliases_file
fi

# load exports
exports_file="$HOME/.exports"
if [[ -r $exports_file ]] && [[ -f $exports_file ]]; then
	source $exports_file
fi
