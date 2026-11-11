#!/bin/bash
# Seam 설치:  ./install.sh
set -e
DIR="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"
BIN="$HOME/.local/bin"

printf '\e[1;36mSeam 설치\e[0m  (%s)\n\n' "$DIR"
chmod +x "$DIR/seam"
mkdir -p "$BIN"
ln -sfn "$DIR/seam" "$BIN/seam-full"
printf '  \e[1;32m✓\e[0m %s/seam -> %s/seam\n' "$BIN" "$DIR"

case ":$PATH:" in
  *":$BIN:"*) printf '  \e[1;32m✓\e[0m PATH 에 %s 있음\n' "$BIN" ;;
  *) if ! grep -qs 'seam: local bin' "$HOME/.bashrc"; then
       printf '\nexport PATH="$HOME/.local/bin:$PATH"  # seam: local bin\n' >> "$HOME/.bashrc"
     fi
     export PATH="$BIN:$PATH"
     printf '  \e[1;32m✓\e[0m ~/.bashrc 에 PATH 추가 (새 터미널부터 적용)\n' ;;
esac

source "$DIR/linux/common.sh"
if _seam_load 2>/dev/null; then
  printf '  \e[1;32m✓\e[0m 설정 있음 (%s) - 기계 추가는 seam setup\n\n' "$SEAM_CONF"
  printf '  이제 \e[1;36mseam\e[0m 을 입력하세요.\n'
else
  echo; "$DIR/seam" setup
fi
