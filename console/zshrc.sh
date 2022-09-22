autoload -Uz add-zsh-hook

case $TERM in
    dumb)
	PS1='$ '
	unsetopt zle
	;;
    *)
	autoload -U colors && colors
        PROMPT=''
        if [[ -n "$SSH_CLIENT" ]]; then
            PROMPT=$PROMPT'%F{cyan}%U%m%u%f '
        fi
        if [[ ! -z $IN_NIX_SHELL ]]; then
            PROMPT=$PROMPT'N '
        fi
        PROMPT=$PROMPT'%B%~%b${vcs_info_msg_0_}
%B%(?,,%F{magenta}[%?]%f )$%b '

	setopt prompt_subst
	autoload -Uz vcs_info
	zstyle ':vcs_info:*' enable git svn hg
	zstyle ':vcs_info:*' check-for-changes true
	zstyle ':vcs_info:*' formats " %F{cyan}%b%c%u%f"
	zstyle ':vcs_info:git*:*' unstagedstr "%F{red}?%f"
	zstyle ':vcs_info:git*:*' stagedstr "%F{green}+%f"
	zstyle ':vcs_info:*' disable-patterns "$HOME/net(|/*)" "/net(|/*)"

	TSL=$(tput tsl)
	FSL=$(tput fsl)

	add-zsh-hook precmd vcs_info
	
	_set_title () {
	    if [[ -z "$1" ]]; then
		print -Pn $TSL"zsh: %~"$FSL
	    else
		print -Pn $TSL"$1: %~"$FSL
	    fi
	}

	add-zsh-hook precmd _set_title
	add-zsh-hook preexec _set_title
        ;;
esac

setopt menu_complete
autoload -U zmv

# prevents nonexec files in PATH coming up
setopt hashexecutablesonly

autoload edit-command-line
zle -N edit-command-line
bindkey "^X^E" edit-command-line

# makes popd work below
setopt autopushd

goBack () {
    popd >/dev/null
    zle reset-prompt
}

goUp () {
    cd ..>/dev/null
    zle reset-prompt
}

zle -N goUp
bindkey '^[u' goUp
zle -N goBack
bindkey '^[i' goBack

WORDCHARS='~!#$%^&*(){}[]<>?.+;-'

zstyle ':completion:*' rehash true
zstyle ':completion:*:*:*:*:*' menu select=2
zstyle ':completion:*:matches' group 'yes'
zstyle ':completion:*:descriptions' format "%{${fg_bold[magenta]}%}%d:%{$reset_color%}"
zstyle ':completion:*' group-name ""
zstyle ':completion:*' accept-exact '*(N)'

# allow speling mistaks
zstyle ':completion:*' completer _complete _approximate
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}

# recent changes first
zstyle ':completion:*' file-sort change

# substring match
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

zstyle ':completion:*:manuals' separate-sections true
zstyle ':completion:*:manuals.(^1*)' insert-sections true
zstyle ':completion:*:default' list-colors ''

alias -g ND='*(/om[1])' # newest directory
alias -g NF='*(.om[1])' # newest file

source ${ZDOTDIR}/plugins/zsh-histdb/histdb-interactive.zsh
bindkey '^r' _histdb-isearch

# _recent_directories () {
#     local words i beginword
#     i=0 
#     beginword=0
#     words=("${(z)BUFFER}") 

#     while (( beginword <= CURSOR )); do
#             (( i++ ))
#             (( beginword += ${#words[$i]}+1 ))
#     done
#     CURRENTWORD="$words[$i]"
#     tmp=$(_histdb_query "select dir from (select places.dir, places.host, max(history.rowid) i from history left join places on history.place_id = places.rowid group by history.place_id) where host = $HISTDB_HOST and dir like '$CURRENTWORD%' order by i desc limit 6")
#     arr=(${(f)tmp})
#     _wanted -V directories expl 'recent' compadd -a arr
# }

# __cd () {
#     _cd
#     _recent_directories
# }

# compdef '__cd' cd

if [[ -f $ZDOTDIR/local.rc ]]; then
    source $ZDOTDIR/local.rc
fi
