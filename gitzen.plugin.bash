#!/usr/bin/env bash
#
# gitzen - git shortcuts for bash
#
# gitzen is a fork of davidde/git (a zsh/oh-my-zsh plugin) with a bash port,
# for distros whose login shell is bash (Omarchy, CachyOS, Arch, ...).
# See README-bash.md for the tag map.
#
# Loading this file defines aliases and functions. It is meant to be SOURCED
# from an interactive shell, e.g. from ~/.bashrc:
#
#     source /path/to/gitzen.plugin.bash
#
# Install it for you with:  ./install.sh --shell bash

# Guard against double-sourcing.
[[ -n ${GITZEN_BASH_LOADED:-} ]] && return 0
GITZEN_BASH_LOADED=1

# Aliases
#############

alias g='git'

alias ga='git add'
alias gaa='git add --all'
alias gai='git add --interactive'
alias galias='git_list_aliases'

# Amend the most recent local commit.
alias gam='git commit --amend -m'
alias gama='git commit --amend -am'
alias gan='git commit --amend --no-edit'
alias gana='git commit --amend --no-edit -a'

alias gap='git add --patch'

alias gb='git branch'
alias gba='git branch --all'
alias gbd='git branch --delete'
alias gbdf='git branch --delete --force'
alias gbl='git blame'
alias gbll='git_blame_line'
alias gbls='git branch --list'
alias gbs='git bisect'
alias gbsb='git bisect bad'
alias gbsg='git bisect good'
alias gbsr='git bisect reset'
alias gbss='git bisect start'

alias gc='git commit --verbose'
alias gcam='git commit -am'
alias gcame='git commit --allow-empty-message -am ""'
alias gcamg='git commit --gpg-sign -am'
alias gcams='git commit --signoff -am'
alias gcamu='git commit -am "Update"'
alias gcad='git commit -a --amend'
alias gcem='git commit --allow-empty -m'
alias gcf='git config'
alias gcfg='git config --global'
alias gcfl='git config --local'
alias gcfls='git config --list'
alias gcl='git_clone_and_cd'
alias gcm='git commit -m'
alias gcmg='git commit --gpg-sign -m'
alias gcms='git commit --signoff -m'
alias gcnt='git_count'
alias gco='git checkout'
alias gcob='git checkout -b'
alias gcobb='git checkout -'
alias gcoc='git_checkout_child'
alias gcod='git checkout develop'
alias gcof='git checkout -f'
alias gcom='git checkout $(git_main_branch)'
alias gcop='git_checkout_parent'
alias gcp='git cherry-pick'
alias gcpa='git cherry-pick --abort'
alias gcpc='git cherry-pick --continue'
alias gcpq='git cherry-pick --quit'
alias gcps='git cherry-pick --skip'

alias gd='git diff'
alias gds='git diff --staged'
alias gdst='git diff stash@{0}'
alias gdsth='git diff stash@{0} HEAD'
alias gdstp='git diff stash@{0}^ stash@{0}'

alias gf='git fetch'
alias gfo='git fetch origin'

alias gg='git log --graph --all --date=format:"%d/%m/%Y" --format=format:"%C(yellow)%h%Creset%x09%C(dim white)%an%Creset%x09%C(bold green)%D%Creset%n%C(white)%ad%Creset%x09%C(bold)%s%Creset%n"'
alias ggb='gg --simplify-by-decoration'
alias ggbo='ggo --simplify-by-decoration'
alias ggo='git log --graph --all --date=format:"%d/%m/%Y" --format=format:"%C(yellow)%h%Creset   %C(white)%ad%Creset   %C(bold)%s   %C(bold green)%D%Creset%n"'

alias gi='git init'
alias gib='git init --bare'

alias gig='git update-index --skip-worktree'
alias gug='git update-index --no-skip-worktree'
alias glsig='git ls-files -v | grep ^S'

alias gl='glog -10'
alias glf='git_log_file'
alias glo='git log --date=format:"%d/%m/%Y" --format=format:"%C(yellow)%h%Creset   %C(white)%ad%Creset   %C(bold)%s   %C(bold green)%D%Creset"'
alias gloc='git_locate_string'
alias glog='git log --reverse --name-status --date=format:"%A %B %d %Y at %H:%M" --format=format:"%C(yellow)%H%Creset%x09%C(bold green)%D%Creset%n%<|(40)%C(white)%ad%x09%an%Creset%n%n    %C(bold)%s%Creset%n%w(0,4,4)%n%-b%n"'

alias glsb='git branch --list'
alias glsf='git ls-files'
alias glsr='git remote -v'
alias glss='git config --file .gitmodules --name-only --get-regexp path'
alias glsst='git stash list'
alias glst='git tag --list'

alias gm='git merge'
alias gmnff='git merge --no-ff'
alias gmom='git merge origin/$(git_main_branch)'
alias gmsq='git merge --squash'
alias gmum='git merge upstream/$(git_main_branch)'
alias gmv='git mv'

alias gph='git push'
alias gphd='git push --delete'
alias gphdo='git push --delete origin'
alias gphf='git push --force-with-lease'
alias gphff='git push --force'
alias gpht='git push && git push --tags'
alias gphu='git push -u'
alias gphuo='git push -u origin'
alias gphuom='git push -u origin main'
alias gpl='git pull'
alias gpla='git pull --autostash'
alias gplr='git pull --rebase'
alias gplrs='git pull --recurse-submodules'

alias gr='git reset'
alias grh='git_reset_head --mixed'
alias grhard='git reset --hard'
alias grhhard='git_reset_head --hard'
alias grhk='git_reset_head --keep'
alias grhs='git_reset_head --soft'
alias grk='git reset --keep'
alias grs='git reset --soft'

alias grb='git rebase'
alias grbm='git rebase $(git_main_branch)'

alias gre='git restore'
alias grea='git restore .'

alias grem='git remote'
alias grema='git remote add'
alias gremao='git remote add origin'
alias gremls='git remote -v'
alias gremrm='git remote rm'
alias gremrmo='git remote rm origin'
alias gremset='git remote set-url'
alias gremseto='git remote set-url origin'
alias gremsh='git remote show'
alias gremv='git remote -v'
alias grl='git reflog'
alias grm='git rm'

alias gs='git status'
alias gsh='git show'
alias gshsf='git_show_stash_file'
alias gss='git_status_short'
alias gst='git stash'
alias gsta='git stash apply'
alias gstd='git stash drop'
alias gstls='git stash list'
alias gstph='git stash push'
alias gstpp='git stash pop'
alias gstshl='git diff stash@{0}' # = git stash show -l
# Show the diff between latest stash and its original parent commit:
alias gstshp='git stash show -p' # = git diff stash@{0}^! = git diff stash@{0}^ stash@{0}

alias gsub='git submodule'
alias gsuba='git submodule add'
alias gsubi='git submodule update --init'
alias gsubf='git submodule foreach'
alias gsubfpl='git submodule foreach git pull'
alias gsubfplom='git submodule foreach git pull origin $(git_main_branch)'
alias gsubs='git submodule status'
alias gsubu='git submodule update --remote --merge'

alias gt='git tag'
alias gtam='git tag -am'
alias gtd='git tag --delete'
alias gtls='git tag --list'
alias gtsm='git tag -sm'
alias gwta='git worktree add'

# Functions
################

# git blame that optionally takes line numbers:
# Usage: gbll <file> [<from line>] [<to line>]
function git_blame_line() {
  local file=$1 from=$2 to=$3
  if [[ -z $file ]]; then
    echo "Usage:    git_blame_line <file> [<from line>] [<to line>]"
    return 1
  elif [[ -z $from ]]; then
    from=1
  elif [[ $from == *,* ]]; then
    to=${from#*,}
    from=${from%,*}
  elif [[ -z $to ]]; then
    to=$from
  fi
  git blame "$file" -L "$from,$to"
}

# Checkout parent/older commit:
# Usage: gcop [<number of commits before HEAD>]
function git_checkout_parent() {
  git checkout "HEAD~${1:-1}"
}

# Checkout child/newer commit:
# Usage: gcoc [<number of commits after HEAD>]
function git_checkout_child() {
  local children child branch
  children=$(git log --all --ancestry-path ^HEAD --format=format:%H | cat)
  if [[ -z $children ]]; then
    echo "This commit does not have any children"
    echo -n 'HEAD remains at '
    git log -1 --oneline | cat
    return 1
  fi

  # Take the first child, or the one specified by the input arg:
  child=$(echo "$children" | tail -n "${1:-1}" | head -n 1)
  # If the child to checkout is at the branch's tip ...
  if [[ "$(echo "$children" | grep -c '')" -le "${1:-1}" ]]; then
    branch=$(git branch --contains "$child" | xargs)
    # ... and there is only 1 branch with that commit ...
    if [[ $branch != *' '* ]]; then
      # ... checkout the branch itself instead of the specific hash:
      child=$branch
    fi
  fi

  git checkout "$child"
}

function git_clone_and_cd() {
  if [[ $# -eq 1 ]]; then
    git clone --recurse-submodules "$1" && cd "$(basename "$1" .git)" || return
  else
    git clone --recurse-submodules "$1" "$2" && cd "$2" || return
  fi
}

function git_count() {
  git shortlog -sn | cat
  echo ''
  echo "$(git rev-list --count HEAD) commits total up to current HEAD"
}

# List all git aliases from the README:
function git_list_aliases() {
  local filename="${GITZEN_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}/README.md"
  local from stop to pad
  if [[ ! -f $filename ]]; then
    echo "git_list_aliases: cannot find $filename" >&2
    return 1
  fi
  from=$(grep -Fno '| **g** ' "$filename" | cut -f1 -d:)
  stop=$(grep -no '&nbsp;' "$filename" | cut -f1 -d:)

  echo '_______________________________________________________________________________
|             |                                                               |
| Alias       | Command                                                       |
|_____________|_______________________________________________________________|
|             |                                                               |'

  if [[ -n $from && -n $stop ]]; then
    to=$((stop - 2))
    sed -n "${from},${to}p" "$filename" |
      tr -d '*\\' |   # Remove **bold** and \ escapes
      sed 's/.$//' |  # Remove last '|' because it is no longer lining up
      while IFS= read -r line; do
        # Left-align the text, then pad to 78 chars and close the row.
        printf '%-78s|\n' "$line"
      done
  fi

  echo '|_____________|_______________________________________________________________|


Note:
This cheatsheet is optimized for memorability,
and may not correspond literally with the actual aliases.

If you want to see all alias implementations, run `alias`.
If you want to see a specific implementation, run `which <alias/function>`.'
}

# Locate all commits in which a specific line of code (string) was first introduced:
# Usage: gloc <Line-of-Code> [<file>]
function git_locate_string() {
  if [[ -z $1 ]]; then
    echo "Usage:    git_locate_string <Line-of-Code> [<file>]"
    return 1
  fi
  gl -S "$1" -- $2
}

# View the full change history of a single file:
# Usage: glf <file> [<from line>] [<to line>]
function git_log_file() {
  local file=$1 from=$2 to=$3
  if [[ -z $file ]]; then
    echo "Usage:    git_log_file <file> [<from line>] [<to line>]"
    return 1
  elif [[ -z $from ]]; then
    glog -p -- "$file"
    return 0
  elif [[ $from == *,* ]]; then
    to=${from#*,}
    from=${from%,*}
  elif [[ -z $to ]]; then
    to=$from
  fi
  glog -L "$from,$to:$file"
}

# Check if main branch exists, otherwise use master branch:
function git_main_branch() {
  if [[ -n "$(git branch --list main)" ]]; then
    echo main
  else
    echo master
  fi
}

# Reset the head to a previous commit (defaults to direct parent):
# Usage: grh [<number of commits before HEAD>]
function git_reset_head() {
  git reset "HEAD~${2:-1}" "$1"
  if [[ $? != 0 ]]; then
    echo -n 'HEAD remains at '
    git log -1 --oneline | cat
    return 1
  elif [[ $1 != '--hard' ]]; then
    echo -n 'HEAD is now at '
    git log -1 --oneline | cat
  fi
}

# Show a specified file from stash x (defaults to latest stash):
# Usage: gshsf <file> [<stash number>]
function git_show_stash_file() {
  if [[ -z $1 ]]; then
    echo "Usage:    git_show_stash_file <file> [<stash number>]"
    return 1
  fi
  git show "stash@{${2:-0}}:$1"
}

# Print short status and log of latest commits:
# Usage: gss [<number of commits>]
function git_status_short() {
  if [[ -z $(git status -s) ]]; then
    echo 'Nothing to commit, working tree clean'
    echo ''
  else
    git status -s && echo ''
  fi
  git log -"${1:-3}" --oneline | cat
}
