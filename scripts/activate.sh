#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HOME_DIR="${HOME:-$HOME}"

usage() {
  cat <<'EOF'
dsh-design activate — 按需激活素材

用法:
  ./scripts/activate.sh skill <name>                  激活一个 skill 到 ~/.agents/skills
  ./scripts/activate.sh template <name> [--to <dir>]   复制模板到指定目录(默认 ./design/session-activate)
  ./scripts/activate.sh design-system <name> [--to <dir>] 复制设计系统到指定目录(默认 ./design/session-activate)
  ./scripts/activate.sh deactivate skill <name>        移除已激活的 skill
  ./scripts/activate.sh deactivate template <name> [--to <dir>] 移除已复制的模板
  ./scripts/activate.sh deactivate design-system <name> [--to <dir>] 移除已复制的设计系统
EOF
}

die() { echo "错误: $*" >&2; exit 1; }

parse_to() {
  TO=""
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --to) TO="$2"; shift 2 ;;
      *) die "未知参数: $1" ;;
    esac
  done
}

cmd="${1:-}"; shift || true
case "$cmd" in
  skill)
    name="${1:-}"; [[ -n "$name" ]] || die "需要 skill 名称"
    src="$ROOT/skills/$name"
    [[ -d "$src" ]] || die "找不到 skill: $src"
    dest="${HOME_DIR}/.agents/skills/$name"
    mkdir -p "$(dirname "$dest")"
    rm -rf "$dest"
    cp -R "$src" "$dest"
    echo "✅ 已激活 skill: $name -> $dest"
    ;;
  template)
    name="${1:-}"; [[ -n "$name" ]] || die "需要 template 名称"
    shift || true
    parse_to "$@"
    src="$ROOT/design-templates/$name"
    [[ -d "$src" ]] || die "找不到 template: $src"
    to="${TO:-$ROOT/design/session-activate}"
    dest="$to/$name"
    mkdir -p "$dest"
    cp -R "$src/." "$dest/"
    echo "✅ 已复制 template: $name -> $dest"
    ;;
  design-system)
    name="${1:-}"; [[ -n "$name" ]] || die "需要 design-system 名称"
    shift || true
    parse_to "$@"
    src="$ROOT/design-systems/$name"
    [[ -d "$src" ]] || die "找不到 design-system: $src"
    to="${TO:-$ROOT/design/session-activate}"
    dest="$to/_design-systems/$name"
    mkdir -p "$dest"
    cp -R "$src/." "$dest/"
    echo "✅ 已复制 design-system: $name -> $dest"
    ;;
  deactivate)
    kind="${1:-}"; shift || true
    case "$kind" in
      skill)
        name="${1:-}"; [[ -n "$name" ]] || die "需要 skill 名称"
        dest="${HOME_DIR}/.agents/skills/$name"
        if [[ -d "$dest" ]]; then rm -rf "$dest"; echo "🗑  已移除 skill: $name"; else echo "未激活: $name"; fi
        ;;
      template|design-system)
        name="${1:-}"; shift || true
        parse_to "$@"
        to="${TO:-$ROOT/design/session-activate}"
        if [[ "$kind" == "design-system" ]]; then
          dest="$to/_design-systems/$name"
        else
          dest="$to/$name"
        fi
        if [[ -d "$dest" ]]; then rm -rf "$dest"; echo "🗑  已移除 $kind: $name"; else echo "未找到: $dest"; fi
        ;;
      *) usage; exit 1 ;;
    esac
    ;;
  *) usage; exit 1 ;;
esac
