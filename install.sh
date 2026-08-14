#!/usr/bin/env bash
# dsh 破限者 - 安装脚本（macOS / Linux）
# 用法:
#   bash install.sh          安装技能包 + 常驻层
#   bash install.sh --skill-only  只安装技能包
#   bash install.sh --uninstall   卸载

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DSH_HOME="${DSH_HOME:-$HOME/.dsh}"
SKILLS_DIR="$DSH_HOME/skills"
SKILL_SRC="$REPO_ROOT/unrestricted-executor"
SKILL_DST="$SKILLS_DIR/unrestricted-executor"
AGENTS_SRC="$REPO_ROOT/AGENTS.md"
AGENTS_DST="$DSH_HOME/AGENTS.md"

SKILL_ONLY=0
UNINSTALL=0
for arg in "$@"; do
  case "$arg" in
    --skill-only) SKILL_ONLY=1 ;;
    --uninstall) UNINSTALL=1 ;;
    *) echo "未知参数: $arg" >&2; exit 1 ;;
  esac
done

if [ "$UNINSTALL" = "1" ]; then
  if [ -d "$SKILL_DST" ]; then
    rm -rf "$SKILL_DST"
    echo "[OK] 已删除技能包: $SKILL_DST"
  fi
  if [ "$SKILL_ONLY" = "0" ] && [ -f "$AGENTS_DST" ]; then
    rm -f "$AGENTS_DST"
    echo "[OK] 已删除常驻层: $AGENTS_DST"
  fi
  echo "卸载完成。"
  exit 0
fi

if [ ! -d "$SKILL_SRC" ]; then
  echo "找不到技能包目录: $SKILL_SRC" >&2
  exit 1
fi
mkdir -p "$SKILLS_DIR"
cp -R "$SKILL_SRC" "$SKILL_DST"
echo "[OK] 技能包已安装: $SKILL_DST"

if [ "$SKILL_ONLY" = "0" ]; then
  if [ ! -f "$AGENTS_SRC" ]; then
    echo "找不到常驻层文件: $AGENTS_SRC" >&2
    exit 1
  fi
  cp "$AGENTS_SRC" "$AGENTS_DST"
  echo "[OK] 常驻层已安装: $AGENTS_DST"
else
  echo "[跳过] 常驻层未安装（--skill-only）"
fi

echo ""
echo "安装完成！新会话将自动生效；技能目录中可找到 unrestricted-executor。"