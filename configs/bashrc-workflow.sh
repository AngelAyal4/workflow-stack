# ============================================================
#  bashrc-workflow.sh — Bloques de aliases y config para .bashrc
#  COPIÁ estos bloques a tu ~/.bashrc (o el setup.sh lo hace solo)
#  ⚠️ NO incluye secretos: el GITHUB_TOKEN va en TU .bashrc local
# ============================================================

# === WORKSPACE ===
alias ws='~/scripts/start-workspace.sh'
alias backup-vault='~/scripts/backup-obsidian.sh'
alias obs='obsidian ~/obsidian-vault &'

# === ZELLIJ ===
alias zj='zellij'
alias zjl='zellij --layout'
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
