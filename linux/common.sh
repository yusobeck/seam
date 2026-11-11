# Seam 공통: 기계 목록 읽기 + ssh 호출
# 기계 목록 ~/.config/seam/machines 한 줄 = 이름 주소(local | ssh 대상) [포트]
SEAM_CONF=${SEAM_CONF:-${XDG_CONFIG_HOME:-$HOME/.config}/seam/machines}
export SEAM="${SEAM:-${XDG_RUNTIME_DIR:-/tmp/seam-$(id -u)}/seam}"
SEAM_VERSION=3.0

_seam_load() {
  SEAM_NAMES=() SEAM_SELF=
  declare -gA SEAM_TARGET=() SEAM_PORT=()
  [ -f "$SEAM_CONF" ] || return 1
  local n t p rest
  while read -r n t p rest; do
    case $n in ''|'#'*) continue ;; esac
    SEAM_NAMES+=("$n"); SEAM_TARGET[$n]=$t; SEAM_PORT[$n]=$p
    [ "$t" = local ] && SEAM_SELF=$n
  done < "$SEAM_CONF"
  [ -n "$SEAM_SELF" ]
}

_seam_others() { local m; for m in "${SEAM_NAMES[@]}"; do [ "$m" = "$SEAM_SELF" ] || echo "$m"; done; }

# _seam_ssh 이름 [ssh옵션...] -- 명령...
_seam_ssh() {
  local m=$1 o=(); shift
  while [ $# -gt 0 ] && [ "$1" != -- ]; do o+=("$1"); shift; done
  [ "$1" = -- ] && shift
  ssh ${SEAM_PORT[$m]:+-p "${SEAM_PORT[$m]}"} -o BatchMode=yes -o ConnectTimeout=5 "${o[@]}" "${SEAM_TARGET[$m]}" "$@"
}

_seam_online() { [ "$1" = "$SEAM_SELF" ] || mountpoint -q "$SEAM/home/$1"; }

_seam_ok()   { printf '  \e[1;32m✓\e[0m %s\n' "$*"; }
_seam_bad()  { printf '  \e[1;31m✗\e[0m %s\n' "$*"; }
_seam_note() { printf '  \e[2m%s\e[0m\n' "$*"; }
