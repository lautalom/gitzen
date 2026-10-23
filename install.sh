#!/usr/bin/env bash
#
# Installer for the lautalom/git bash plugin (git shortcuts).
#
# Usage:
#   ./install.sh               # install
#   ./install.sh --uninstall   # remove what this script installed
#   ./install.sh --help
#
# Piped install, no manual checkout required:
#   curl -fsSL https://raw.githubusercontent.com/lautalom/git/main/install.sh | bash
#
set -euo pipefail

PROG="$(basename "${BASH_SOURCE[0]:-$0}")"
REPO_URL="${GIT_PLUGIN_REPO:-https://github.com/lautalom/git.git}"
LIB_DIR="${GIT_PLUGIN_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/git-plugin}"
RC="$HOME/.bashrc"

MARK_BEGIN="# >>> git-plugin (lautalom/git) >>>"
MARK_END="# <<< git-plugin (lautalom/git) <<<"

ACTION="install"   # install | uninstall

if [ -t 1 ]; then
  C_BLUE=$'\033[1;34m'; C_GREEN=$'\033[1;32m'; C_YELLOW=$'\033[1;33m'; C_RED=$'\033[1;31m'; C_OFF=$'\033[0m'
else
  C_BLUE=''; C_GREEN=''; C_YELLOW=''; C_RED=''; C_OFF=''
fi
info() { printf '%s==>%s %s\n' "$C_BLUE" "$C_OFF" "$*"; }
ok()   { printf '%s  ok%s %s\n' "$C_GREEN" "$C_OFF" "$*"; }
warn() { printf '%swarning:%s %s\n' "$C_YELLOW" "$C_OFF" "$*" >&2; }
die()  { printf '%serror:%s %s\n' "$C_RED" "$C_OFF" "$*" >&2; exit 1; }

usage() {
  cat <<EOF
$PROG - install git shortcuts for bash

Options:
  -u, --uninstall   Remove the block this script added to ~/.bashrc.
      --repo <url>  Git remote to clone (default: $REPO_URL).
      --dir <path>  Checkout location when not run from a clone (default: $LIB_DIR).
  -h, --help        Show this help.
EOF
}

while [ $# -gt 0 ]; do
  case "$1" in
    -u|--uninstall) ACTION="uninstall"; shift ;;
    --repo)         REPO_URL="${2:-}"; shift 2 ;;
    --dir)          LIB_DIR="${2:-}"; shift 2 ;;
    -h|--help)      usage; exit 0 ;;
    *)              die "unknown argument: $1 (try --help)" ;;
  esac
done

SRC_DIR=""
SRC_LOCAL=0

locate_source() {
  local here=""
  here="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd || true)"
  if [ -n "$here" ] && [ -f "$here/git.plugin.bash" ]; then
    SRC_DIR="$here"; SRC_LOCAL=1
    return 0
  fi

  if [ -d "$LIB_DIR/.git" ]; then
    info "Updating plugin checkout in $LIB_DIR"
    git -C "$LIB_DIR" pull --ff-only --quiet 2>/dev/null || warn "could not update $LIB_DIR; using what is there"
  else
    info "Cloning $REPO_URL into $LIB_DIR"
    mkdir -p "$(dirname "$LIB_DIR")"
    git clone --quiet "$REPO_URL" "$LIB_DIR"
  fi
  SRC_DIR="$LIB_DIR"
}

backup_once() {
  [ -s "$RC" ] || return 0
  if ! grep -qF "$MARK_BEGIN" "$RC" 2>/dev/null; then
    local bak="$RC.bak.$(date +%s)"
    cp -a "$RC" "$bak"
    ok "backed up $(basename "$RC") -> $(basename "$bak")"
  fi
}

strip_block() {
  [ -f "$RC" ] || return 0
  local tmp; tmp="$(mktemp)"
  awk -v b="$MARK_BEGIN" -v e="$MARK_END" '
    $0 == b { skip = 1 }
    skip && $0 == e { skip = 0; next }
    skip { next }
    { print }
  ' "$RC" > "$tmp"

  # Drop trailing blank lines so re-installs don't accumulate them.
  awk '{ lines[NR] = $0 }
       END {
         last = NR
         while (last > 0 && lines[last] ~ /^[[:space:]]*$/) last--
         for (i = 1; i <= last; i++) print lines[i]
       }' "$tmp" > "$tmp.2"
  cat "$tmp.2" > "$RC"
  rm -f "$tmp" "$tmp.2"
}

install_plugin() {
  locate_source
  if [ "$SRC_LOCAL" = 1 ]; then ok "using local checkout $SRC_DIR"; else ok "sources ready in $SRC_DIR"; fi

  [ -f "$RC" ] || : > "$RC"
  backup_once
  strip_block
  {
    printf '\n%s\n' "$MARK_BEGIN"
    printf 'source "%s/git.plugin.bash"\n' "$SRC_DIR"
    printf '%s\n' "$MARK_END"
  } >> "$RC"
  ok "updated $(basename "$RC")"

  if grep -qs omarchy /etc/os-release 2>/dev/null; then
    info "Omarchy ships its own aliases (g, gcm, gcam, gcad)."
    info "This plugin is sourced after them and wins, except for 'gcad'."
  fi

  printf '\n'
  ok "Installed. To use it now, run:  source ~/.bashrc"
  printf '    Then try:  gs\n'
  if [ "$SRC_LOCAL" != 1 ]; then
    printf '    Update later with:  git -C "%s" pull  (or re-run this installer)\n' "$SRC_DIR"
  fi
}

if [ "$ACTION" = uninstall ]; then
  info "Uninstalling git-plugin"
  strip_block
  ok "removed git-plugin block from $(basename "$RC")"
else
  install_plugin
fi
