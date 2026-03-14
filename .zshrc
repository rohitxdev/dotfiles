# --- Performance: instant prompt (put at top before anything slow) ---
export ZINIT_HOME="$HOME/.local/share/zinit/zinit.git"
if [[ ! -f $ZINIT_HOME/zinit.zsh ]]; then
  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi
source "$ZINIT_HOME/zinit.zsh"

# Plugins (zinit lazy-loads these — stays fast)
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light Aloxaf/fzf-tab              # fzf for tab completion

# --- History ---
HISTFILE="$HOME/.zsh_history"
HISTSIZE=100000
SAVEHIST=100000
setopt SHARE_HISTORY          # sync across sessions
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE      # don't save lines starting with space
setopt EXTENDED_HISTORY       # timestamps

# --- Options ---
setopt AUTO_CD                # cd by typing directory name
setopt CORRECT                # typo correction
setopt NO_BEEP

# --- Completions ---
autoload -Uz compinit
compinit -C                   # -C skips regeneration check (fast; run `compinit` manually after installs)
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'  # case-insensitive

# --- Keybindings ---
bindkey -e                    # emacs mode (ctrl+a, ctrl+e, ctrl+r etc.)
bindkey '^[[A' history-search-backward   # up arrow: search history by prefix
bindkey '^[[B' history-search-forward

# --- fzf ---
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border --bind ctrl-j:down,ctrl-k:up'

# --- zoxide ---
export PATH="$HOME/.local/bin:$PATH"
eval "$(zoxide init zsh)"
alias cd='z'                  # or keep `z` separate if you prefer

# --- dotfiles ---
export DOTFILES_DIR="$HOME/.dotfiles"
alias dot="/usr/bin/env git --git-dir=$DOTFILES_DIR --work-tree=$HOME"

# --- Aliases: modern replacements ---
alias ls='eza --icons --group-directories-first'
alias ll='eza -la --icons --git --group-directories-first'
alias lt='eza --tree --level=2 --icons'
alias cat='bat --style=auto'
alias top='btop'              # needs btop installed

# --- Aliases: misc ---
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias mkdir='mkdir -p'
alias cp='cp -iv'
alias mv='mv -iv'
alias rm='rm -iv'             # confirm before destructive ops
alias ports='ss -tulnp'
alias path='echo $PATH | tr ":" "\n"'

# --- tmux ---
t() {
    tmux new -A -s "${1:-main}";
}

# --- direnv ---
eval "$(direnv hook zsh)"

# --- Starship prompt (must be last) ---
eval "$(starship init zsh)"

# if command -v tmux >/dev/null 2>&1 && [ -z "$TMUX" ] && [ -n "$PS1" ]; then
#   tmux new -A -s main
# fi