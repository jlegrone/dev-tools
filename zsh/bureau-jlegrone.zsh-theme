# oh-my-zsh Bureau Theme

### USER/HOST overrides
USER_TO_OVERRIDE="jlegrone"
USER_OVERRIDE=""
HOST_TO_OVERRIDE="Jacobs-MacBook-Pro.local"
HOST_OVERRIDE=""

### NVM

ZSH_THEME_NVM_PROMPT_PREFIX="%B⬡%b "
ZSH_THEME_NVM_PROMPT_SUFFIX=""

### Git [±master ▾●]

ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg_bold[green]%}± %{$reset_color%}%{$fg_bold[magenta]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg_bold[green]%}✓%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_AHEAD="%{$fg[cyan]%}▴%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_BEHIND="%{$fg[magenta]%}▾%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_STAGED="%{$fg_bold[green]%}●%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_UNSTAGED="%{$fg_bold[yellow]%}●%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$fg_bold[red]%}●%{$reset_color%}"

bureau_git_branch () {
  ref=$(command git symbolic-ref HEAD 2> /dev/null) || \
  ref=$(command git rev-parse --short HEAD 2> /dev/null) || return
  echo "${ref#refs/heads/}"
}

bureau_git_status() {
  _STATUS=""

  # check status of files
  _INDEX=$(command git status --porcelain 2> /dev/null)
  if [[ -n "$_INDEX" ]]; then
    if $(echo "$_INDEX" | command grep -q '^[AMRD]. '); then
      _STATUS="$_STATUS$ZSH_THEME_GIT_PROMPT_STAGED"
    fi
    if $(echo "$_INDEX" | command grep -q '^.[MTD] '); then
      _STATUS="$_STATUS$ZSH_THEME_GIT_PROMPT_UNSTAGED"
    fi
    if $(echo "$_INDEX" | command grep -q -E '^\?\? '); then
      _STATUS="$_STATUS$ZSH_THEME_GIT_PROMPT_UNTRACKED"
    fi
    if $(echo "$_INDEX" | command grep -q '^UU '); then
      _STATUS="$_STATUS$ZSH_THEME_GIT_PROMPT_UNMERGED"
    fi
  else
    _STATUS="$_STATUS$ZSH_THEME_GIT_PROMPT_CLEAN"
  fi

  # check status of local repository
  _INDEX=$(command git status --porcelain -b 2> /dev/null)
  if $(echo "$_INDEX" | command grep -q '^## .*ahead'); then
    _STATUS="$_STATUS$ZSH_THEME_GIT_PROMPT_AHEAD"
  fi
  if $(echo "$_INDEX" | command grep -q '^## .*behind'); then
    _STATUS="$_STATUS$ZSH_THEME_GIT_PROMPT_BEHIND"
  fi
  if $(echo "$_INDEX" | command grep -q '^## .*diverged'); then
    _STATUS="$_STATUS$ZSH_THEME_GIT_PROMPT_DIVERGED"
  fi

  if $(command git rev-parse --verify refs/stash &> /dev/null); then
    _STATUS="$_STATUS$ZSH_THEME_GIT_PROMPT_STASHED"
  fi

  echo $_STATUS
}

bureau_git_prompt () {
  local _branch=$(bureau_git_branch)
  local _status=$(bureau_git_status)
  local _result=""
  if [[ "${_branch}x" != "x" ]]; then
    _result="$ZSH_THEME_GIT_PROMPT_PREFIX$_branch"
    if [[ "${_status}x" != "x" ]]; then
      _result="$_result $_status"
    fi
    _result="$_result$ZSH_THEME_GIT_PROMPT_SUFFIX"
  fi
  echo $_result
}

_PATH="%{$fg_bold[cyan]%}%~%{$reset_color%}"

_USERNAME="%{$fg[green]%}%n%{$reset_color%}@"
if [ "$USER" = "$USER_TO_OVERRIDE" ]; then
  _USERNAME="$USER_OVERRIDE"
fi
_HOSTNAME=$(hostname -f)
if [ "$_HOSTNAME" = "$HOST_TO_OVERRIDE" ]; then
  _HOSTNAME="$HOST_OVERRIDE"
else
  _HOSTNAME="%{$fg[green]%}%m%{$reset_color%} "
fi

if [[ $EUID -eq 0 ]]; then
  _LIBERTY="%{$fg[red]%}#"
else
  _LIBERTY="%{$fg[yellow]%}$"
fi
_USERNAME="$_USERNAME$_HOSTNAME"
_LIBERTY="$_LIBERTY%{$reset_color%}"

get_space () {
  local STR=$1$2
  local CHAR=$3
  local zero='%([BSUbfksu]|([FB]|){*})'
  local LENGTH=${#${(S%%)STR//$~zero/}}
  local SPACES=""
  (( LENGTH = ${COLUMNS} - $LENGTH - 1))

  for i in {0..$LENGTH}
    do
      SPACES="$SPACES$CHAR"
    done

  echo $SPACES
}

# _1LEFT="$_PATH $(nvm_prompt_info)"
_1LEFT="%F{black}$_USERNAME%f$_PATH"
_1RIGHT="%* "
# _1RIGHT="%F{black}$_USERNAME%f %* "

bureau_precmd () {
  _1SPACES=`get_space $_1LEFT $_1RIGHT " "`
  print -P '%F{black}`get_space "" " " "-"`%f'
  print -rP "$_1LEFT$_1SPACES$_1RIGHT"
}

setopt prompt_subst
PROMPT='$_LIBERTY '
# RPROMPT='$(nvm_prompt_info) $(bureau_git_prompt)'
RPROMPT='$(bureau_git_prompt)'

autoload -U add-zsh-hook
add-zsh-hook precmd bureau_precmd
