# ============================================================
#  bashrc-workflow.sh — Bloques de aliases y config para .bashrc
#  COPIÁ estos bloques a tu ~/.bashrc (o el setup.sh lo hace solo)
#  ⚠️ NO incluye secretos: el GITHUB_TOKEN va en TU .bashrc local
# ============================================================

# === WORKSPACE ===
# ws abre UNA TERMINAL NUEVA en vista maximizada (con botones min/rest/cerrar)
ws() {
    gnome-terminal --maximize -- bash -c 'exec ~/scripts/start-workspace.sh "$@"' _ "$@"
}
alias backup-vault='~/scripts/backup-obsidian.sh'
alias obs='obsidian ~/obsidian-vault &'

# ======= ZELLIJ (secundario) / TMUX (principal, mas estable) =======
alias zj='zellij'
alias zjl='zellij --layout'
# tmux es el multiplexor principal (mas estable). ws lanza `ws-<stack>-<proyecto>`
alias tml='tmux ls'
alias tma='tmux attach -t'
alias da='direnv allow'
alias dr='direnv reload'

# === OPENCODE ===
alias oc='opencode'

# === GIT ===
alias gs='git status'
alias ga='git add .'
alias gc='git commit -m'
alias gp='git push'
alias gl='git log --oneline -10'

# === DIRENV (hook) ===
eval "$(direnv hook bash)"

# === GITHUB TOKEN (agregalo VOS, no se comparte) ===
# export GITHUB_TOKEN="ghp_TU_TOKEN_AQUI"
