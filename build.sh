#!/usr/bin/env bash
# DeepSeek Harness - Intel Mac 一键构建脚本
# 用途：在 Intel (x86_64) Mac 上从官方源码编译桌面版 dmg 安装包
# 产物：~/deepseek-harness/apps/desktop/.desktop-build/targets/mac-x64/unsigned-artifacts/*.dmg
set -euo pipefail

# ---- 配置 ----
SRC_DIR="${DSH_SRC_DIR:-$HOME/deepseek-harness}"
GH_MIRROR="${GH_MIRROR:-https://gh-proxy.com/https://github.com}"
ELECTRON_MIRROR="${ELECTRON_MIRROR:-https://npmmirror.com/mirrors/electron/}"

echo "==> [1/4] 检查前置依赖"
command -v node >/dev/null || { echo "错误: 未找到 node，请先安装 Node.js >= 22.19（官网 pkg 版，需带开发头文件）"; exit 1; }
command -v pnpm >/dev/null || { echo "错误: 未找到 pnpm，请执行: corepack enable && corepack prepare pnpm@11.28.5 --activate"; exit 1; }
command -v git >/dev/null || { echo "错误: 未找到 git"; exit 1; }
xcode-select -p >/dev/null 2>&1 || { echo "错误: 未安装 Xcode Command Line Tools，请执行: xcode-select --install"; exit 1; }

# 校验 Node 带开发头文件（编译原生模块必需）
NODE_BIN="$(command -v node)"
NODE_ROOT="$(dirname "$NODE_BIN")/.."
if [ ! -f "$NODE_ROOT/include/node/node_api.h" ]; then
  echo "警告: 当前 node ($NODE_BIN) 缺少开发头文件 (include/node)，原生模块编译会失败。"
  echo "       若系统装有官方版 Node（如 /usr/local/bin/node），脚本将自动使用它。"
  if [ -f /usr/local/bin/node ] && [ -f /usr/local/include/node/node_api.h ]; then
    export PATH="/usr/local/bin:$PATH"
    echo "==> 已切换到 /usr/local/bin/node"
  else
    echo "错误: 没有可用的带头文件 Node。请安装官网 pkg 版 Node.js 后重试。"
    exit 1
  fi
fi

echo "==> [2/4] 拉取官方源码"
if [ ! -d "$SRC_DIR/.git" ]; then
  echo "    尝试直连 GitHub..."
  if ! GIT_TERMINAL_PROMPT=0 git -c http.lowSpeedLimit=1000 -c http.lowSpeedTime=20 clone --depth 1 \
      https://github.com/deepseek-ai/deepseek-harness.git "$SRC_DIR" 2>/dev/null; then
    echo "    直连失败，改用镜像 ${GH_MIRROR}..."
    GIT_TERMINAL_PROMPT=0 git -c http.lowSpeedLimit=1000 -c http.lowSpeedTime=20 clone --depth 1 \
      "${GH_MIRROR}/deepseek-ai/deepseek-harness.git" "$SRC_DIR"
  fi
else
  echo "    源码已存在，拉取最新..."
  git -C "$SRC_DIR" pull --ff-only || echo "    提示: 如需强制更新可删除 $SRC_DIR 后重跑"
fi

cd "$SRC_DIR"

echo "==> [3/4] 安装依赖并全量编译（耗时较长，请耐心等待）"
export PATH="/usr/local/bin:$PATH"
pnpm install
pnpm run build

echo "==> [4/4] 打包 Intel (x86_64) dmg"
export ELECTRON_MIRROR
pnpm --filter @deepseek-ai/dsh-desktop run package:mac:x64:unsigned

echo ""
echo "==> 构建完成！产物位置："
ls -lh "$SRC_DIR/apps/desktop/.desktop-build/targets/mac-x64/unsigned-artifacts/"*.dmg
echo ""
echo "==> 安装：双击 dmg，将 DeepSeek Harness.app 拖入 Applications 文件夹。"
