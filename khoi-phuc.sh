#!/usr/bin/env bash
# BOOTSTRAP khoi phuc may moi. File nay CO Y de PUBLIC — khong chua bi mat nao:
# khong token, khong khoa, khong IP may chu. No chi biet duong den kho rieng, va
# kho do van khoa bang git-crypt.
#
#   bash <(curl -sL https://raw.githubusercontent.com/zeroxsg85/claude-khoi-phuc/main/khoi-phuc.sh)
set -uo pipefail
KHO_RIENG="zeroxsg85/claude-brain-sync"
DICH="$HOME/.claude/brain-sync"
buoc(){ printf '\n\033[1m== %s\033[0m\n' "$*"; }
hoi(){ printf '\033[33m%s\033[0m ' "$*"; }
# Script nay chay ca trong terminal that LAN trong khung chat Claude (khong co ban phim).
# Khong co TTY thi tuyet doi khong `read` — se treo mai. Lay tu bien moi truong roi dung
# lai voi huong dan ro rang.
co_ban_phim(){ [[ -t 0 ]]; }

buoc "1/5 Cong cu"
thieu=()
for c in git node curl; do command -v "$c" >/dev/null || thieu+=("$c"); done
if ((${#thieu[@]})); then
  echo "  thieu: ${thieu[*]}"
  echo "  Ubuntu/Mint : sudo apt update && sudo apt install -y git nodejs curl"
  echo "  macOS       : brew install git node curl"
  echo "  Windows     : winget install Git.Git OpenJS.NodeJS"
  exit 1
fi
command -v gh >/dev/null || { echo "  (khong bat buoc) gh chua co — se dung git thuong"; }
echo "  git $(git --version | awk '{print $3}') | node $(node -v)"

buoc "2/5 Quyen vao GitHub"
if git ls-remote "https://github.com/$KHO_RIENG.git" >/dev/null 2>&1; then
  echo "  da co quyen"
else
  echo "  Chua dang nhap GitHub. Chon MOT cach:"
  echo "    a) gh auth login          (de nhat, lam theo huong dan tren man hinh)"
  echo "    b) dan Personal Access Token khi git hoi Username/Password"
  echo "       -> Username: zeroxsg85 | Password: <token>"
  echo "       Tao token: https://github.com/settings/tokens (quyen 'repo')"
  if co_ban_phim; then
    hoi "Dang nhap xong thi bam Enter de thu lai (hoac Ctrl-C de thoat):"; read -r _
  else
    echo
    echo "  >> Dang chay trong khung chat (khong co ban phim). Mo mot Terminal that,"
    echo "     chay 'gh auth login' hoac 'git config --global credential.helper store'"
    echo "     roi chay lai lenh nay."
    exit 2
  fi
  git ls-remote "https://github.com/$KHO_RIENG.git" >/dev/null 2>&1 || {
    echo "  van chua vao duoc, dung lai."; exit 1; }
  echo "  ok"
fi

buoc "3/5 git-crypt"
if ! command -v git-crypt >/dev/null; then
  sudo apt-get install -y git-crypt 2>/dev/null || {
    tmp=$(mktemp -d)
    (cd "$tmp" && apt-get download git-crypt >/dev/null 2>&1 &&
     dpkg-deb -x ./*.deb "$HOME/.local/opt/git-crypt" &&
     mkdir -p "$HOME/.local/bin" &&
     ln -sf "$HOME/.local/opt/git-crypt/usr/bin/git-crypt" "$HOME/.local/bin/git-crypt")
    export PATH="$HOME/.local/bin:$PATH"
  }
fi
command -v git-crypt >/dev/null || {
  echo "  Khong cai duoc git-crypt. Cach khac:"
  echo "    macOS  : brew install git-crypt"
  echo "    Windows: winget install AGWA.git-crypt"
  exit 1; }
echo "  co git-crypt"

buoc "4/5 Tai kho ve va mo khoa"
if [[ -d "$DICH/.git" ]]; then git -C "$DICH" pull -q --rebase --autostash || true
else mkdir -p "$(dirname "$DICH")" && git clone -q "https://github.com/$KHO_RIENG.git" "$DICH"; fi
echo "  da tai ve $DICH"
if git -C "$DICH" crypt status >/dev/null 2>&1; then
  echo "  da mo khoa tu truoc"
else
  echo "  Can file khoa 'brain-sync.key' (148 byte). Lay o mot trong ba noi:"
  echo "    - trinh quan ly mat khau: muc 'brain-sync.key', dang base64 mot dong"
  echo "    - may chu rieng: /root/.config/brain-sync.key"
  echo "    - USB/ban in da cat truoc do"
  echo "  Neu dang co chuoi base64, tao lai file bang:"
  echo "    echo '<chuoi>' | base64 -d > ~/brain-sync.key && chmod 600 ~/brain-sync.key"
  if [[ -n "${KHOA_BASE64:-}" ]]; then
    printf '%s' "$KHOA_BASE64" | base64 -d > "$HOME/brain-sync.key" && chmod 600 "$HOME/brain-sync.key"
    k="$HOME/brain-sync.key"; echo "  da dung lai khoa tu bien KHOA_BASE64"
  elif [[ -n "${KHOA:-}" ]]; then
    k="$KHOA"
  elif co_ban_phim; then
    hoi "Duong dan toi file khoa (Enter = ~/brain-sync.key):"; read -r k
    k="${k:-$HOME/brain-sync.key}"
  elif [[ -f "$HOME/brain-sync.key" ]]; then
    k="$HOME/brain-sync.key"; echo "  dung khoa san co o ~/brain-sync.key"
  else
    echo
    echo "  >> Dang chay trong khung chat, khong hoi ban duoc. Chay lai kem khoa:"
    echo "     KHOA_BASE64='<chuoi base64 trong trinh quan ly mat khau>' bash <(curl -sL ...)"
    echo "     hoac dat san file ~/brain-sync.key roi chay lai."
    exit 3
  fi
  [[ -f "$k" ]] || { echo "  khong thay $k"; exit 1; }
  git -C "$DICH" crypt unlock "$k" || { echo "  mo khoa that bai (sai khoa?)"; exit 1; }
  echo "  da mo khoa"
fi

buoc "5/5 Dung lai bo nho va cac du an"
exec bash "$DICH/scripts/khoi-phuc.sh" "${KHOA:-$HOME/brain-sync.key}"
