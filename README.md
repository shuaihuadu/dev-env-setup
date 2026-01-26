# Dev Environment Setup

快速在 Linux/macOS 上搭建完整开发环境的自动化工具集。

## ✨ 特性

- 🚀 一键安装开发工具（前端、后台、数据库、云）
- 🔧 SSH 端口安全配置（支持 Ubuntu 24.04 systemd socket）
- 📦 常用 dotfiles 配置
- 🐧 支持 Ubuntu/Debian, CentOS/RHEL, macOS

## 📁 项目结构

```
dev-env-setup/
├── install.sh              # 一键安装入口
├── Makefile                # 常用命令
├── scripts/
│   ├── lib/
│   │   └── common.sh           # 公共函数库
│   ├── install/
│   │   └── dev-tools.sh        # 开发工具安装
│   └── ssh/
│       ├── change-port.sh      # SSH 端口修改
│       └── status.sh           # SSH 状态查看
└── configs/                # 配置文件
    ├── .bashrc
    ├── .zshrc
    ├── .gitconfig
    ├── .vimrc
    └── .editorconfig
```

## 🚀 快速开始

### 方式一：克隆仓库

```bash
git clone https://github.com/shuaihuadu/dev-env-setup.git
cd dev-env-setup
make help
```

### 方式二：一键安装（远程）

```bash
curl -fsSL https://raw.githubusercontent.com/shuaihuadu/dev-env-setup/main/install.sh | bash
```

## 📋 可用命令

```bash
make help                        # 显示帮助信息
make install-tools               # 安装开发工具（已安装的自动跳过）
make ssh-port                    # 修改 SSH 端口
make ssh-status                  # 查看当前 SSH 端口状态
make dotfiles                    # 安装配置文件（支持逐个确认）
make set-terminal-theme          # 选择并设置 Oh My Zsh 主题（自动安装 Oh My Zsh）
make restore-terminal-to-default # 恢复默认终端配置（macOS→zsh, Linux→bash）
make check                       # 检查脚本语法
make list                        # 列出所有脚本
make clean                       # 清理临时文件 (*.bak, *~)
```

> 💡 `make clean` 只清理项目目录内的临时文件（备份文件 `*.bak` 和编辑器临时文件 `*~`），不会影响 `$HOME` 目录。

## 🔧 安装的工具

### 前端
- nvm, Node.js, npm, pnpm, yarn
- Bun, TypeScript, Vite
- ESLint, Prettier

### 后台
- Go, Python/pip/uv
- Java/Maven/Gradle, .NET SDK
- protobuf, grpcurl

### 数据库客户端
- PostgreSQL (psql)
- Redis (redis-cli)
- SQLite

### 云和 DevOps
- Docker, Docker Compose
- kubectl, Helm, Terraform
- Azure CLI, AWS CLI, gcloud
- Ansible

### 通用工具
- Git, GitHub CLI
- jq, yq, mkcert

## 🔐 SSH 端口修改

| 功能           | 说明                        |
| -------------- | --------------------------- |
| 端口选项       | 22 (默认) / 22389 / 自定义  |
| 用户确认       | 修改前显示确认信息          |
| 配置备份       | 自动备份到 `.backup.时间戳` |
| 语法验证       | 使用 `sshd -t` 验证         |
| 防火墙         | 自动检测 UFW/firewalld      |
| systemd socket | 支持 Ubuntu 22.04/24.04     |

## 📦 Dotfiles 配置文件

### 什么是 Dotfiles？

**Dotfiles** 是你的个人配置文件集合，决定了你使用各种开发工具时的行为和体验。之所以叫 "dotfiles"，是因为这些文件都以 `.` 开头（如 `.bashrc`），在 Unix 系统中是隐藏文件。

### 为什么要统一管理？

- **快速恢复环境**：换新电脑或开新服务器时，运行 `make dotfiles` 即可恢复所有熟悉的快捷命令和配置
- **版本控制**：配置文件纳入 Git 管理，可以追踪变更、回滚错误配置
- **团队协作**：`.editorconfig` 确保团队成员使用一致的代码风格，减少无意义的 diff

### 配置文件说明

运行 `make dotfiles` 会将 `configs/` 目录下的配置文件安装到 `$HOME`：

| 文件            | 用途            | 解决什么问题                                                   |
| --------------- | --------------- | -------------------------------------------------------------- |
| `.bashrc`       | Bash shell 配置 | 定义命令别名（如 `gs` → `git status`）、环境变量、彩色提示符   |
| `.zshrc`        | Zsh shell 配置  | 同上，适用于 Zsh 用户，兼容 Oh My Zsh                          |
| `.gitconfig`    | Git 全局配置    | 设置用户名/邮箱、常用别名，无需每台机器重新配置                |
| `.vimrc`        | Vim 编辑器配置  | 启用行号、语法高亮、缩进等，告别"裸奔" Vim                     |
| `.editorconfig` | 编辑器统一配置  | 统一缩进风格（空格/Tab）、换行符、编码，避免 PR 中充斥空格差异 |

### 包含的实用别名

```bash
# Git 快捷命令
gs    → git status
ga    → git add
gc    → git commit
gp    → git push
glog  → git log --oneline --graph --decorate

# Docker 快捷命令
dk    → docker
dkps  → docker ps
dkimg → docker images

# Kubernetes 快捷命令 (仅 .zshrc 包含)
k     → kubectl
kgp   → kubectl get pods
kga   → kubectl get all
```

> 💡 如果你使用 Bash 并需要 kubectl 别名，可以手动添加到 `~/.bashrc.local` 文件中。

### 安装说明

运行 `make dotfiles` 时会：
- ✅ 逐个询问是否安装每个配置文件（支持跳过）
- ✅ Git 配置时会交互式输入用户名和邮箱
- ✅ 自动备份已存在的配置文件（备份为 `.bak` 文件）
- ✅ 将新配置复制到 `$HOME` 目录
- ✅ 运行 `source ~/.bashrc` 或重新登录后生效

### Oh My Zsh 主题设置

使用 `make set-terminal-theme` 可以：
- 🎨 选择 10+ 个流行的 Oh My Zsh 主题（如 agnoster, bira, ys 等）
- 🔍 自动检测并提示安装 Oh My Zsh（如未安装）
- 💾 自动备份当前配置，设置失败会自动恢复
- 🌈 支持所有 [Oh My Zsh 内置主题](https://github.com/ohmyzsh/ohmyzsh/wiki/Themes)

```bash
make set-terminal-theme
# 根据提示选择主题并确认
source ~/.zshrc  # 生效
```

### 恢复默认配置

如果配置出错或想重置，使用 `make restore-terminal-to-default`：
- 🔄 macOS 自动恢复 `.zshrc`，Linux 自动恢复 `.bashrc`
- 💾 自动备份当前配置（带时间戳）
- ✅ 失败时自动回滚

```bash
make restore-terminal-to-default
# 确认后恢复到项目的默认配置
```

### 别名与系统命令冲突

别名的优先级**高于**系统命令。如果你定义了 `alias foo='xxx'`，而系统中也有 `/usr/bin/foo`，直接输入 `foo` 会执行别名。

**绕过别名，执行原始命令：**

```bash
\foo              # 方法1：反斜杠前缀
/usr/bin/foo      # 方法2：使用完整路径
command foo       # 方法3：command 内置命令
```

**检查命令类型：**

```bash
type foo          # 查看 foo 是别名还是系统命令
type -a ls        # 查看所有同名定义（别名 + 系统命令）
```

> ⚠️ 注意：配置中的 `fd()` 函数可能与 [fd-find](https://github.com/sharkdp/fd) 工具冲突。如果你安装了 fd-find，可以删除 `.bashrc` / `.zshrc` 中的 `fd()` 函数。

## ⚠️ 安装后建议

安装完成后，建议重启系统以确保所有环境变量和服务配置生效：

```bash
sudo reboot
```

或者至少重新登录当前用户：

```bash
# 刷新当前 shell 环境
source ~/.bashrc

# 或者退出重新登录
exit
```

## 📄 License

MIT License

