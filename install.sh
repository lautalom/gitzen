#!/usr/bin/env bash
#
# Universal installer for gitzen - git shortcuts for bash / zsh / nushell.
#
# gitzen is a fork of davidde/git with a bash port, aimed at distros whose
# login shell is bash, such as Omarchy and CachyOS (Arch-based, Hyprland).
#
# Usage:
#   ./install.sh                 # auto-detect (bash on bash-login distros)
#   ./install.sh --shell bash    # force bash
#   ./install.sh --shell zsh     # force zsh
#   ./install.sh --shell nu      # force nushell
#   ./install.sh --all           # install for every supported shell found
#   ./install.sh --uninstall     # remove what this script installed
#   ./install.sh --help
#
# Piped install, no manual checkout required:
#   bash <(curl -fsSL https://raw.githubusercontent.com/lautalom/gitzen/main/install.sh)
#
set -euo pipefail

PROG="$(basename "${BASH_SOURCE[0]:-$0}")"
REPO_URL="${GITZEN_REPO:-https://github.com/lautalom/gitzen.git}"
LIB_DIR="${GITZEN_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/gitzen}"

MARK_BEGIN="# >>> gitzen >>>"
MARK_END="# <<< gitzen <<<"

MODE="auto"        # auto | bash | zsh | nu | all
ACTION="install"   # install | uninstall
WITH_ZSH=0         # install zsh via the package manager if missing

# ---------------------------------------------------------------------------
# Output helpers
# ---------------------------------------------------------------------------
if [ -t 1 ]; then
  C_BLUE=$'\033[1;34m'; C_GREEN=$'\033[1;32m'; C_YELLOW=$'\033[1;33m'; C_RED=$'\033[1;31m'; C_OFF=$'\033[0m'
else
  C_BLUE=''; C_GREEN=''; C_YELLOW=''; C_RED=''; C_OFF=''
fi
info() { printf '%s==>%s %s\n' "$C_BLUE" "$C_OFF" "$*"; }
ok()   { printf '%s  ok%s %s\n' "$C_GREEN" "$C_OFF" "$*"; }
warn() { printf '%swarning:%s %s\n' "$C_YELLOW" "$C_OFF" "$*" >&2; }
die()  { printf '%serror:%s %s\n' "$C_RED" "$C_OFF" "$*" >&2; exit 1; }
have() { command -v "$1" >/dev/null 2>&1; }

# ---------------------------------------------------------------------------
# Argument parsing
# ---------------------------------------------------------------------------
usage() {
  cat <<EOF
$PROG - install git shortcuts for bash / zsh / nushell (Omarchy, CachyOS, Arch, ...)

Options:
  -s, --shell <bash|zsh|nu|all>  Which shell(s) to configure (default: auto).
      --all                      Same as --shell all.
  -u, --uninstall                Remove installed plugin/config entries.
      --with-zsh                 Install zsh via the system package manager if missing.
      --repo <url>               Git remote to clone (default: $REPO_URL).
      --dir <path>               Install/checkout location (default: $LIB_DIR).
  -h, --help                     Show this help.
EOF
}

while [ $# -gt 0 ]; do
  case "$1" in
    -s|--shell)   MODE="${2:-}"; shift 2 ;;
    --all)        MODE="all"; shift ;;
    -u|--uninstall) ACTION="uninstall"; shift ;;
    --with-zsh)   WITH_ZSH=1; shift ;;
    --repo)       REPO_URL="${2:-}"; shift 2 ;;
    --dir)        LIB_DIR="${2:-}"; shift 2 ;;
    -h|--help)    usage; exit 0 ;;
    *)            die "unknown argument: $1 (try --help)" ;;
  esac
done

case "$MODE" in auto|bash|zsh|nu|all) ;; *) die "invalid --shell '$MODE' (use bash, zsh, nu or all)" ;; esac

# ---------------------------------------------------------------------------
# Distro detection + friendly package hints
# ---------------------------------------------------------------------------
DISTRO="unknown"
if [ -r /etc/os-release ]; then
  # shellcheck disable=SC1091
  DISTRO="$(. /etc/os-release 2>/dev/null; printf '%s' "${ID:-unknown}")"
fi

pkg_hint() {
  case "$DISTRO" in
    omarchy)                                  printf 'omarchy pkg add %s' "$1" ;;
    cachyos|arch|endeavouros|manjaro|garuda)  printf 'sudo pacman -S --needed %s' "$1" ;;
    ubuntu|debian|pop|linuxmint)              printf 'sudo apt install %s' "$1" ;;
    fedora)                                   printf 'sudo dnf install %s' "$1" ;;
    *)                                        printf "install '%s' with your package manager" "$1" ;;
  esac
}

install_pkg() {
  local pkg="$1"
  if [ "$DISTRO" = omarchy ] && have omarchy; then
    omarchy pkg add "$pkg"
  elif have pacman; then
    sudo pacman -S --needed "$pkg"
  elif have apt; then
    sudo apt install -y "$pkg"
  elif have dnf; then
    sudo dnf install -y "$pkg"
  elif have brew; then
    brew install "$pkg"
  else
    die "don't know how to install '$pkg' on this system"
  fi
}

# ---------------------------------------------------------------------------
# Locate (or fetch) the plugin sources
# ---------------------------------------------------------------------------
SRC_DIR=""
SRC_LOCAL=0

locate_source() {
  local here=""
  here="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd || true)"
  if [ -n "$here" ] && { [ -f "$here/gitzen.plugin.bash" ] || [ -f "$here/gitzen.plugin.zsh" ]; }; then
    SRC_DIR="$here"; SRC_LOCAL=1
    return 0
  fi

  if [ -d "$LIB_DIR/.git" ]; then
    info "Updating plugin checkout in $LIB_DIR"
    git -C "$LIB_DIR" pull --ff-only --quiet 2>/dev/null || warn "could not update $LIB_DIR; using what is there"
  elif [ -f "$LIB_DIR/gitzen.plugin.bash" ] || [ -f "$LIB_DIR/gitzen.plugin.zsh" ]; then
    info "Using existing plugin checkout in $LIB_DIR"
  else
    info "Cloning $REPO_URL into $LIB_DIR"
    mkdir -p "$(dirname "$LIB_DIR")"
    git clone --quiet "$REPO_URL" "$LIB_DIR"
  fi
  SRC_DIR="$LIB_DIR"
}

# ---------------------------------------------------------------------------
# Managed config blocks
# ---------------------------------------------------------------------------
backup_once() {
  local file="$1"
  [ -f "$file" ] || return 0
  [ -s "$file" ] || return 0
  # Only back up the first time we touch a file (i.e. before markers exist).
  if ! grep -qF "$MARK_BEGIN" "$file" 2>/dev/null; then
    local bak="$file.bak.$(date +%s)"
    cp -a "$file" "$bak"
    ok "backed up $(basename "$file") -> $(basename "$bak")"
  fi
}

strip_block() {
  local file="$1"
  [ -f "$file" ] || return 0
  local tmp; tmp="$(mktemp)"
  awk -v b="$MARK_BEGIN" -v e="$MARK_END" '
    $0 == b { skip = 1 }
    skip && $0 == e { skip = 0; next }
    skip { next }
    { print }
  ' "$file" > "$tmp"

  # Drop trailing blank lines so re-installs don't accumulate them.
  awk 'BEGIN { n = 0 }
       { lines[NR] = $0 }
       END {
         last = NR
         while (last > 0 && lines[last] ~ /^[[:space:]]*$/) last--
         for (i = 1; i <= last; i++) print lines[i]
       }' "$tmp" > "$tmp.2"
  cat "$tmp.2" > "$file"
  rm -f "$tmp" "$tmp.2"
}

add_block() {
  local file="$1" source_line="$2"
  mkdir -p "$(dirname "$file")"
  [ -f "$file" ] || : > "$file"
  backup_once "$file"
  strip_block "$file"
  {
    printf '\n%s\n' "$MARK_BEGIN"
    printf '%s\n' "$source_line"
    printf '%s\n' "$MARK_END"
  } >> "$file"
  ok "updated $(basename "$file")"
}

# ---------------------------------------------------------------------------
# bash
# ---------------------------------------------------------------------------
bash_rc() {
  printf '%s/.bashrc' "$HOME"
}

install_bash() {
  local rc; rc="$(bash_rc)"
  add_block "$rc" "source \"$SRC_DIR/gitzen.plugin.bash\""
  ok "bash shortcuts will load in new shells on this machine"
  if [ "$DISTRO" = omarchy ]; then
    info "Omarchy also ships its own few git aliases (g, gcm, gcam, gcad)."
    info "This plugin is sourced after them and wins, except for 'gcad',"
    info "which is kept so Omarchy's 'git commit -a --amend' still works."
  fi
}

uninstall_bash() {
  local rc; rc="$(bash_rc)"
  strip_block "$rc"
  ok "removed gitzen block from $(basename "$rc")"
}

# ---------------------------------------------------------------------------
# zsh
# ---------------------------------------------------------------------------
zsh_rc() {
  if [ -n "${ZDOTDIR:-}" ]; then printf '%s/.zshrc' "$ZDOTDIR"; else printf '%s/.zshrc' "$HOME"; fi
}

install_zsh() {
  local rc; rc="$(zsh_rc)"
  local zsh_root="${ZSH:-$HOME/.oh-my-zsh}"
  local zsh_custom="${ZSH_CUSTOM:-$zsh_root/custom}"

  if [ -d "$zsh_root" ] && [ -d "$zsh_custom" ]; then
    # oh-my-zsh: drop the plugin into the custom plugins directory.
    local target="$zsh_custom/plugins/gitzen"
    mkdir -p "$zsh_custom/plugins"
    if [ -L "$target" ] && [ "$(readlink -f "$target")" = "$(readlink -f "$SRC_DIR")" ]; then
      ok "oh-my-zsh plugin already linked at $target"
    else
      [ -e "$target" ] && { mv "$target" "$target.bak.$(date +%s)"; warn "moved existing $(basename "$target") aside"; }
      ln -s "$SRC_DIR" "$target"
      ok "linked oh-my-zsh plugin -> $target"
    fi
    ensure_omz_plugin_enabled "$rc"
  else
    # Plain zsh: source the plugin from the managed block.
    add_block "$rc" "source \"$SRC_DIR/gitzen.plugin.zsh\""
  fi
}

ensure_omz_plugin_enabled() {
  local rc="$1"
  [ -f "$rc" ] || { : > "$rc"; }
  if grep -qE '^[[:space:]]*plugins[^#]*\bgitzen\b' "$rc"; then
    ok "oh-my-zsh already loads the 'gitzen' plugin"
    return 0
  fi

  # Find the line that loads oh-my-zsh; plugins must be set before it.
  local omz_line
  omz_line=$(grep -nE '^[[:space:]]*(source|\.)[[:space:]]+.*oh-my-zsh\.sh' "$rc" | head -1 | cut -d: -f1)

  backup_once "$rc"

  if grep -qE '^[[:space:]]*plugins=\([^)]*\)[[:space:]]*$' "$rc"; then
    # Single-line array: append to the end so gitzen wins over the default git plugin.
    sed -i -E '0,/^([[:space:]]*plugins=\([^)]*)\)[[:space:]]*$/s//\1 gitzen)/' "$rc"
    sed -i -E '0,/^([[:space:]]*)plugins=\( /s//\1plugins=(/' "$rc"
    ok "added 'gitzen' to the plugins array in $(basename "$rc")"
  elif [ -n "$omz_line" ] && [ "$omz_line" -gt 1 ]; then
    # Multi-line (or absent) array: add an additive line just before oh-my-zsh loads.
    local tmp; tmp="$(mktemp)"
    awk -v n="$omz_line" 'NR==n { print "plugins+=(gitzen)" } { print }' "$rc" > "$tmp"
    cat "$tmp" > "$rc"
    rm -f "$tmp"
    ok "added 'plugins+=(gitzen)' before oh-my-zsh loads in $(basename "$rc")"
  else
    printf '\nplugins+=(gitzen)\n' >> "$rc"
    warn "could not find the oh-my-zsh source line; added 'plugins+=(gitzen)' at the end of $(basename "$rc")"
  fi

  if grep -qE '^[[:space:]]*plugins[^#]*\bgit\b' "$rc"; then
    warn "the default oh-my-zsh 'git' plugin is also enabled; gitzen is listed last, so it wins"
  fi
}

uninstall_zsh() {
  local rc; rc="$(zsh_rc)"
  local zsh_root="${ZSH:-$HOME/.oh-my-zsh}"
  local zsh_custom="${ZSH_CUSTOM:-$zsh_root/custom}"
  local target="$zsh_custom/plugins/gitzen"
  if [ -L "$target" ]; then
    rm -f "$target"
    ok "removed oh-my-zsh plugin link $target"
    if grep -qE '^[[:space:]]*plugins.*\bgitzen\b' "$rc"; then
      warn "left 'gitzen' in the plugins list of $(basename "$rc") (remove it manually if unwanted)"
    fi
  fi
  strip_block "$rc"
  ok "removed gitzen block from $(basename "$rc")"
}

# ---------------------------------------------------------------------------
# nushell
# ---------------------------------------------------------------------------
nu_config() {
  printf '%s/nushell/config.nu' "${XDG_CONFIG_HOME:-$HOME/.config}"
}

install_nu() {
  local cfg; cfg="$(nu_config)"
  add_block "$cfg" "source \"$SRC_DIR/gitzen.plugin.nu\""
}

uninstall_nu() {
  local cfg; cfg="$(nu_config)"
  strip_block "$cfg"
  ok "removed gitzen block from $(basename "$cfg")"
}

# ---------------------------------------------------------------------------
# Guidance when a shell is missing
# ---------------------------------------------------------------------------
guide_missing() {
  local shell="$1"
  warn "$shell is not installed"
  printf '    install it with:  %s\n' "$(pkg_hint "$shell")"
  printf '    then re-run:      %s --shell %s\n' "$PROG" "$shell"
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
main() {
  local want_bash=0 want_zsh=0 want_nu=0
  case "$MODE" in
    bash) want_bash=1 ;;
    zsh)  want_zsh=1 ;;
    nu)   want_nu=1 ;;
    all)  want_bash=1; want_zsh=1; want_nu=1 ;;
    auto)
      # bash is always present; on Omarchy/CachyOS it is the login shell, so
      # it is the safe default. Only pick zsh/nu when that is the active shell.
      local cur; cur="$(basename "${SHELL:-}")"
      case "$cur" in
        zsh) want_zsh=1 ;;
        nu)  want_nu=1 ;;
        *)   want_bash=1 ;;
      esac
      ;;
  esac

  if [ "$ACTION" = uninstall ]; then
    info "Uninstalling gitzen"
    [ "$want_bash" = 1 ] && uninstall_bash
    [ "$want_zsh" = 1 ] && uninstall_zsh
    [ "$want_nu" = 1 ] && uninstall_nu
    ok "done"
    return 0
  fi

  # Optionally install zsh before wiring anything up.
  if [ "$want_zsh" = 1 ] && ! have zsh && [ "$WITH_ZSH" = 1 ]; then
    info "Installing zsh via package manager"
    install_pkg zsh
    hash -r 2>/dev/null || true
  fi

  if [ "$want_zsh" = 1 ] && ! have zsh; then
    guide_missing zsh
    [ "$want_bash" = 1 ] || [ "$want_nu" = 1 ] || exit 1
    want_zsh=0
  fi
  if [ "$want_nu" = 1 ] && ! have nu; then
    guide_missing nu
    [ "$want_bash" = 1 ] || [ "$want_zsh" = 1 ] || exit 1
    want_nu=0
  fi

  locate_source
  if [ "$SRC_LOCAL" = 1 ]; then ok "using local checkout $SRC_DIR"; else ok "sources ready in $SRC_DIR"; fi

  local reload=""
  if [ "$want_bash" = 1 ]; then
    info "Configuring bash"
    install_bash
    reload="source ~/.bashrc"
  fi
  if [ "$want_zsh" = 1 ]; then
    info "Configuring zsh"
    install_zsh
    [ -z "$reload" ] && reload="source ~/.zshrc"
  fi
  if [ "$want_nu" = 1 ]; then
    info "Configuring nushell"
    install_nu
    [ -z "$reload" ] && reload="restart nushell"
  fi

  printf '\n'
  ok "Installed. To use it now, run:  ${reload:-open a new shell}"
  printf '    Then try:  gs\n'
  if [ "$SRC_LOCAL" != 1 ]; then
    printf '    Update later with:  git -C "%s" pull  (or re-run this installer)\n' "$SRC_DIR"
  fi
}

main
