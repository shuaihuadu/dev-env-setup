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
    ├── .gitconfig
    └── .vimrc
```

## 🚀 快速开始

### 方式一：克隆仓库

```bash
git clone https://github.com/shuaihua/dev-env-setup.git
cd dev-env-setup
make help
```

### 方式二：一键安装（远程）

```bash
curl -fsSL https://raw.githubusercontent.com/shuaihua/dev-env-setup/main/install.sh | bash
```

## 📋 可用命令

```bash
make help        # 显示帮助信息
make tools       # 安装全部开发工具
make ssh-port    # 修改 SSH 端口
make ssh-status  # 查看当前 SSH 端口状态
make dotfiles    # 安装配置文件
make install     # 安装脚本到系统
make uninstall   # 卸载脚本
make check       # 检查脚本语法
make list        # 列出所有脚本
```

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

| 功能 | 说明 |
|------|------|
| 端口选项 | 22 (默认) / 22389 / 自定义 |
| 用户确认 | 修改前显示确认信息 |
| 配置备份 | 自动备份到 `.backup.时间戳` |
| 语法验证 | 使用 `sshd -t` 验证 |
| 防火墙 | 自动检测 UFW/firewalld |
| systemd socket | 支持 Ubuntu 22.04/24.04 |

## 📦 Dotfiles 配置文件

运行 `make dotfiles` 会将 `configs/` 目录下的配置文件安装到 `$HOME`：

| 文件 | 用途 |
|------|------|
| `.bashrc` | Bash 配置（命令别名、环境变量、提示符样式） |
| `.gitconfig` | Git 全局配置（用户信息、常用别名） |
| `.vimrc` | Vim 编辑器配置 |

**安装时会：**
- 如果目标文件已存在，自动备份为 `.bak` 文件
- 然后复制新配置到 `$HOME` 目录

> 💡 "dotfiles" 名称来源于 Unix 惯例：以 `.` 开头的文件是隐藏的配置文件。

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

