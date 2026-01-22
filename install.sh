#!/bin/bash

#===============================================================================
# 一键安装入口脚本
# 支持: Ubuntu/Debian, CentOS/RHEL, macOS
#===============================================================================

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# 仓库信息
REPO_URL="https://github.com/shuaihua/dev-env-setup"
INSTALL_DIR="$HOME/.dev-env-setup"

print_header() {
    echo -e "${CYAN}"
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║           Dev Environment Setup Installer                      ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检测操作系统
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
    elif [[ -f /etc/os-release ]]; then
        . /etc/os-release
        OS=$ID
    else
        OS="unknown"
    fi
    echo "$OS"
}

# 检查依赖
check_dependencies() {
    local missing=()
    
    for cmd in git curl; do
        if ! command -v "$cmd" &> /dev/null; then
            missing+=("$cmd")
        fi
    done
    
    if [[ ${#missing[@]} -gt 0 ]]; then
        print_warning "缺少依赖: ${missing[*]}"
        print_info "正在安装依赖..."
        
        case $(detect_os) in
            ubuntu|debian)
                sudo apt-get update && sudo apt-get install -y "${missing[@]}"
                ;;
            centos|rhel|fedora)
                sudo yum install -y "${missing[@]}"
                ;;
            macos)
                print_error "请先安装 Xcode Command Line Tools: xcode-select --install"
                exit 1
                ;;
            *)
                print_error "请手动安装: ${missing[*]}"
                exit 1
                ;;
        esac
    fi
}

# 克隆或更新仓库
setup_repo() {
    if [[ -d "$INSTALL_DIR" ]]; then
        print_info "更新已有安装..."
        cd "$INSTALL_DIR"
        git pull --quiet
    else
        print_info "克隆仓库..."
        git clone --quiet "$REPO_URL" "$INSTALL_DIR"
    fi
}

# 显示菜单
show_menu() {
    echo ""
    echo -e "${YELLOW}请选择要执行的操作:${NC}"
    echo ""
    echo "  1) 安装全部开发工具 (推荐)"
    echo "  2) 仅修改 SSH 端口"
    echo "  3) 安装配置文件 (dotfiles)"
    echo "  4) 查看可用脚本"
    echo "  q) 退出"
    echo ""
}

# 运行开发工具安装
run_tools() {
    print_info "运行开发工具安装..."
    sudo bash "$INSTALL_DIR/scripts/install-dev-tools.sh"
}

# 运行 SSH 端口配置
run_ssh_port() {
    print_info "运行 SSH 端口配置..."
    sudo bash "$INSTALL_DIR/scripts/change-ssh-port.sh"
}

# 安装 dotfiles
install_dotfiles() {
    local configs_dir="$INSTALL_DIR/configs"
    
    if [[ ! -d "$configs_dir" ]]; then
        print_warning "配置文件目录不存在"
        return
    fi
    
    print_info "安装配置文件..."
    
    for config in "$configs_dir"/.*; do
        [[ -f "$config" ]] || continue
        local filename=$(basename "$config")
        local target="$HOME/$filename"
        
        if [[ -f "$target" ]]; then
            print_warning "$filename 已存在，备份为 ${filename}.bak"
            cp "$target" "${target}.bak"
        fi
        
        cp "$config" "$target"
        print_success "已安装 $filename"
    done
}

# 列出可用脚本
list_scripts() {
    echo ""
    echo -e "${CYAN}可用脚本:${NC}"
    echo ""
    for script in "$INSTALL_DIR/scripts/"*.sh; do
        [[ -f "$script" ]] || continue
        local name=$(basename "$script" .sh)
        echo -e "  ${GREEN}$name${NC}"
    done
    echo ""
}

# 主程序
main() {
    print_header
    
    # 检测系统
    local os=$(detect_os)
    print_info "检测到系统: $os"
    
    # 检查依赖
    check_dependencies
    
    # 如果是远程执行，先克隆仓库
    if [[ ! -d "$INSTALL_DIR" ]] && [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
        setup_repo
    fi
    
    # 如果本地已有仓库，使用本地路径
    if [[ -f "./scripts/install-dev-tools.sh" ]]; then
        INSTALL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    fi
    
    # 交互式菜单
    while true; do
        show_menu
        read -p "请输入选项: " choice
        
        case $choice in
            1)
                run_tools
                break
                ;;
            2)
                run_ssh_port
                break
                ;;
            3)
                install_dotfiles
                ;;
            4)
                list_scripts
                ;;
            q|Q)
                print_info "已退出"
                exit 0
                ;;
            *)
                print_error "无效选项"
                ;;
        esac
    done
    
    echo ""
    print_success "操作完成！"
}

# 支持直接运行或通过 curl 管道执行
main "$@"
