#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
OUT="$ROOT/catalog.md"

{
  echo "# dsh-design 资源索引"
  echo ""
  echo "> 自动生成，请勿手改。运行 \`./scripts/generate-catalog.sh\` 更新。"
  echo ""
  echo "## Templates ($(find design-templates -mindepth 1 -maxdepth 1 -type d ! -name '_*' | wc -l | tr -d ' '))"
  echo ""
  echo '| 名称 | 说明 |'
  echo '|---|---|'
  for d in design-templates/*/; do
    name="$(basename "$d")"
    [[ "$name" == _* ]] && continue
    desc="$(head -5 "$d/SKILL.md" 2>/dev/null | grep -m1 '^description:' | sed 's/^description: *//' || true)"
    echo "| $name | ${desc:-} |"
  done
  echo ""
  echo "## Design Systems ($(find design-systems -mindepth 1 -maxdepth 1 -type d ! -name '_*' | wc -l | tr -d ' '))"
  echo ""
  echo '| 名称 | 说明 |'
  echo '|---|---|'
  for d in design-systems/*/; do
    name="$(basename "$d")"
    [[ "$name" == _* ]] && continue
    desc="$(head -10 "$d/DESIGN.md" 2>/dev/null | grep -m1 '^#' | sed 's/^#* *//' || true)"
    echo "| $name | ${desc:-} |"
  done
  echo ""
  echo "## Skills ($(find skills -mindepth 1 -maxdepth 1 -type d ! -name '_*' | wc -l | tr -d ' '))"
  echo ""
  echo '| 名称 | 说明 |'
  echo '|---|---|'
  for d in skills/*/; do
    name="$(basename "$d")"
    [[ "$name" == _* ]] && continue
    desc="$(head -8 "$d/SKILL.md" 2>/dev/null | grep -m1 '^description:' | sed 's/^description: *//' || true)"
    echo "| $name | ${desc:-} |"
  done
  echo ""
  echo "## Prompt Templates"
  echo ""
  echo "- image: $(find prompt-templates/image -maxdepth 1 -name '*.json' | wc -l | tr -d ' ') 个"
  echo "- video: $(find prompt-templates/video -maxdepth 1 -name '*.json' | wc -l | tr -d ' ') 个"
} > "$OUT"
echo "✅ catalog.md 已更新"
