#!/usr/bin/env bash
set -euo pipefail

DOTFILES_REPO="https://github.com/rohitxdev/dotfiles.git"
DOTFILES_DIR="$HOME/.dotfiles"
BACKUP_DIR="$HOME/.dotfiles-backup"

sudo apt update

# --- Packages ---
sudo apt install -y zsh tmux git curl fzf bat btop direnv

# --- eza ---
sudo mkdir -p /etc/apt/keyrings
wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc \
  | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" \
  | sudo tee /etc/apt/sources.list.d/gierens.list
sudo apt update
sudo apt install -y eza

# --- zoxide ---
curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh

# --- starship ---
curl -sS https://starship.rs/install.sh | sh -s -- --yes

# --- git identity ---
current_name=$(git config --global user.name 2>/dev/null || true)
current_email=$(git config --global user.email 2>/dev/null || true)

read -rp "Git name [${current_name:-none}]: " input_name
read -rp "Git email [${current_email:-none}]: " input_email

git config --global user.name "${input_name:-$current_name}"
git config --global user.email "${input_email:-$current_email}"

# --- dotfiles ---
dot() { /usr/bin/git --git-dir="$DOTFILES_DIR" --work-tree="$HOME" "$@"; }

if [[ ! -d "$DOTFILES_DIR" ]]; then
  git clone --bare "$DOTFILES_REPO" "$DOTFILES_DIR"
fi

dot config --local status.showUntrackedFiles no

# Back up conflicting files then checkout
mkdir -p "$BACKUP_DIR"
if ! dot checkout 2>/dev/null; then
  echo "Backing up conflicting files to $BACKUP_DIR"
  dot checkout 2>&1 \
    | grep "^\s" \
    | awk '{print $1}' \
    | xargs -I{} bash -c 'mkdir -p "$1/$(dirname "$2")" && mv "$HOME/$2" "$1/$2"' _ "$BACKUP_DIR" {}
  dot checkout
fi

# Move install script out of home dir into bare repo
[[ -f "$HOME/install.sh" ]] && mv "$HOME/install.sh" "$DOTFILES_DIR/install.sh"

# --- Default shell ---
chsh -s "$(which zsh)"

echo ""
echo "Done. Open a new terminal to start using zsh."
echo "Conflicting files (if any) backed up to $BACKUP_DIR"