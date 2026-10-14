# DeepSeek Harness — Intel Mac 构建版

DeepSeek Harness（DSH）官方源码在 **Intel (x86_64) Mac** 上编译的桌面安装包与一键构建脚本。

> 官方仓库目前只发布 **Apple Silicon (arm64)** 的 macOS 安装包，Intel Mac 用户无法直接使用。本仓库解决这个缺口：提供可直接安装的 **Intel 版 dmg**，并附上可复现的编译脚本。

## 📦 下载

前往 [Releases](https://github.com/<YOUR_USERNAME>/deepseek-harness-intel-build/releases) 下载最新版：

- `DeepSeek-Harness-Intel-mac-x64.dmg`（约 366MB，Intel Mac 专用）

## 🖥️ 系统要求

- macOS 13.0 及以上（Intel / x86_64）
- 磁盘空间：至少 5GB（dmg 安装后应用约 1GB+）

## ⚙️ 安装方法

1. 下载 `DeepSeek-Harness-Intel-mac-x64.dmg`
2. 双击打开，将 **DeepSeek Harness.app** 拖入 Applications 文件夹
3. 首次打开如果提示「无法验证开发者」，请 **右键点击图标 → 打开**，再次确认即可（本地构建、未做 Apple 公证，属正常提示）
4. 打开后按界面提示填入 DeepSeek API Key 即可使用

## 🔨 自己编译（可复现）

### 前置依赖

- Node.js `^22.19.0` 或 `>=24.0.0`（**必须带开发头文件**，官网 pkg 安装版即可）
- pnpm `11.28.5`（`corepack enable && corepack prepare pnpm@11.28.5 --activate`）
- Xcode Command Line Tools（`xcode-select --install`）

> ⚠️ 注意：不要使用精简版 Node（无 `include/node` 头文件），否则原生模块编译会失败。

### 一键脚本

```bash
chmod +x build.sh
./build.sh
```

脚本会依次执行：拉取官方源码（含国内镜像加速）→ 安装依赖 → 全量编译 → 打包 Intel dmg。产物输出到 `~/deepseek-harness/apps/desktop/.desktop-build/targets/mac-x64/unsigned-artifacts/`。

### 手动步骤（等价）

```bash
# 1. 拉取官方源码（国内网络推荐用 gh-proxy 镜像）
git clone --depth 1 https://github.com/deepseek-ai/deepseek-harness.git ~/deepseek-harness
# 或：git clone --depth 1 https://gh-proxy.com/https://github.com/deepseek-ai/deepseek-harness.git ~/deepseek-harness

cd ~/deepseek-harness

# 2. 安装依赖（务必使用带头文件的系统 Node）
PATH=/usr/local/bin:$PATH pnpm install

# 3. 全量编译
PATH=/usr/local/bin:$PATH pnpm run build

# 4. 打包 Intel 版 dmg（Electron 走国内镜像加速）
PATH=/usr/local/bin:$PATH ELECTRON_MIRROR=https://npmmirror.com/mirrors/electron/ \
  pnpm --filter @deepseek-ai/dsh-desktop run package:mac:x64:unsigned
```

## 📋 版本信息

| 项目 | 内容 |
|---|---|
| 上游仓库 | [deepseek-ai/deepseek-harness](https://github.com/deepseek-ai/deepseek-harness)（MIT） |
| DSH 版本 | 0.2.1-alpha.2 |
| 桌面应用 | `@deepseek-ai/dsh-desktop`（官方 Electron 桌面封装） |
| 架构 | x86_64（Intel） |
| 签名 | ad-hoc（未公证） |

## 🛠️ 常见问题

**Q：打开提示「无法验证开发者」？**
A：右键 → 打开，或到 系统设置 → 隐私与安全性 → 仍要打开。

**Q：为什么不是官方发布的？**
A：官方 Releases 暂未提供 mac-x64 安装包，本仓库由官方公开源码编译，与官方产品一致，但由社区维护分发。

**Q：为什么 dmg 这么大（366MB）？**
A：应用内置了完整运行时（Node、pnpm、文档转换等），无需用户额外配置。

**Q：如何升级？**
A：重新运行 `build.sh` 拉取最新源码编译即可（增量构建，比首次快）。

## ⚖️ 版权与许可

- 本项目仅对官方开源代码做构建分发，**未修改任何源码**。
- 上游 [deepseek-ai/deepseek-harness](https://github.com/deepseek-ai/deepseek-harness) 采用 MIT 协议，本仓库沿用 MIT。
- 请遵守上游项目的品牌与使用规范。
