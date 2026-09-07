#!/bin/bash
# Touch ID for sudo: enable pam_tid in /etc/pam.d/sudo_local (Apple's designated file — it
# survives macOS updates, unlike /etc/pam.d/sudo). Runs first so every later sudo in the
# bootstrap can use the fingerprint. Idempotent; asks for the password once the first time.
set -euf -o pipefail

#- Logging: tee all output to a shared log (also stays on the terminal)
chezmoi_log_dir="${XDG_STATE_HOME:-$HOME/.local/state}/chezmoi"
mkdir -p "$chezmoi_log_dir"
exec > >(tee -a "$chezmoi_log_dir/install.log") 2>&1
printf '\n===== %s  %s =====\n' "$(date '+%F %T')" "$(basename -- "$0")"

f=/etc/pam.d/sudo_local
if [ -f "$f" ] && grep -Eq '^auth[[:space:]]+sufficient[[:space:]]+pam_tid\.so' "$f"; then
  echo ">>> Touch ID for sudo already enabled ($f)"
  exit 0
fi

echo ">>> Enabling Touch ID for sudo (needs your password this one time)"
sudo -v
if [ -f "$f.template" ]; then
  # Apple's template ships with the auth line commented out — uncomment it.
  sudo sh -c "sed 's/^#auth/auth/' '$f.template' > '$f'"
else
  printf 'auth       sufficient     pam_tid.so\n' | sudo tee "$f" >/dev/null
fi
sudo chmod 444 "$f"
echo ">>> Done: $(grep pam_tid "$f")"
