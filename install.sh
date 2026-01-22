#!/bin/bash

#===============================================================================
# 一键安装入口脚本
# 支持: Ubuntu/Debian, CentOS/RHEL, macOS
#===============================================================================

set -e

# 获取脚本目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 仓库信息
REPO_URL="https://github.com/shuaihuadu/dev-env-setup"
INSTALL_DIR="$HOME/.dev-env-setup"

#===============================================================================
# 公共函数（支持独立运行和远程 curl 执行）
#===============================================================================

# 尝试加载公共库，如果不存在则使用内置函数
load_common_lib() {
    local lib_path="$SCRIPT_DIR/scripts/lib/common.sh"
    if [[ -f "$lib_path" ]]; then
        source "$lib_path"
        return 0
    fi
    return 1
}

# 如果无法加载公共库，定义基础函数
if ! load_common_lib; then
    # 颜色定义
    if [ -t 1 ]; then
        RED='\033[0;31m'
        GREEN='\033[0;32m'
        YELLOW='\033[1;33m'
        BLUE='\033[0;34m'
        CYAN='\033[0;36m'
        NC='\033[0m'
    else
        RED='' GREEN='' YELLOW='' BLUE='' CYAN='' NC=''
    fi

    log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
    log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
    log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
    log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
    
    command_exists() { command -v "$1" &> /dev/null; }
    
    detect_os() {
        if [[ "$OSTYPE" == "darwin"* ]]; then
            echo "macos"
        elif [[ -f /etc/os-release ]]; then
            . /etc/os-release
            echo "$ID"
        else
            echo "unknown"
        fi
    }
    
    print_header() {
        local title="${1:-Dev Environment Setup}"
        echo -e "${CYAN}"
        echo "╔════════════════════════════════════════════════════════════════╗"
        printf "║%*s%s%*s║\n" $(( (62 - ${#title}) / 2 )) "" "$title" $(( (63 - ${#title}) / 2 )) ""
        echo "╚════════════════════════════════════════════════════════════════╝"
        echo -e "${NC}"
    }
fi

# 检测操作系统（设置全局变量）
OS=$(detect_os)

#===============================================================================
# 依赖检查
#===============================================================================

check_dependencies() {
    local missing=()
    
    for cmd in git curl; do
        if ! command_exists "$cmd"; then
            missing+=("$cmd")
        fi
    done
    
    if [[ ${#missing[@]} -gt 0 ]]; then
        log_warning "缺少依赖: ${missing[*]}"
        log_info "正在安装依赖..."
        
        case $OS in
            ubuntu|debian)
                sudo apt-get update && sudo apt-get install -y "${missing[@]}"
                ;;
            centos|rhel|fedora)
                sudo yum install -y "${missing[@]}"
                ;;
            macos)
                log_error "请先安装 Xcode Command Line Tools: xcode-select --install"
                exit 1
                ;;
            *)
                log_error "请手动安装: ${missing[*]}"
                exit 1
                ;;
        esac
    fi
}

#===============================================================================
# 仓库管理
#===============================================================================

setup_repo() {
    if [[ -d "$INSTALL_DIR" ]]; then
        log_info "更新已有安装..."
        cd "$INSTALL_DIR"
        git pull --quiet
    else
        log_info "克隆仓库..."
        git clone --quiet "$REPO_URL" "$INSTALL_DIR"
    fi
}

#===============================================================================
# 菜单和操作
#===============================================================================

show_menu() {
    echo ""
    echo -e "${YELLOW}请选择要执行的操作:${NC}"
    echo ""
    echo "  1) 安装全部开发工具 (推荐)"
    echo "  2) 修改 SSH 端口"
    echo "  3) 查看 SSH 端口状态"
    echo "  4) 安装配置文件 (dotfiles)"
    echo "  5) 查看可用脚本"
    echo "  q) 退出"
    echo ""
}

run_tools() {
    log_info "运行开发工具安装..."
    chmod +x "$INSTALL_DIR/scripts/lib/common.sh"
    chmod +x "$INSTALL_DIR/scripts/install/dev-tools.sh"
    sudo bash "$INSTALL_DIR/scripts/install/dev-tools.sh"
}

run_ssh_port() {
    log_info "运行 SSH 端口配置..."
    chmod +x "$INSTALL_DIR/scripts/lib/common.sh"
    chmod +x "$INSTALL_DIR/scripts/ssh/change-port.sh"
    sudo bash "$INSTALL_DIR/scripts/ssh/change-port.sh"
}

run_ssh_status() {
    chmod +x "$INSTALL_DIR/scripts/lib/common.sh"
    chmod +x "$INSTALL_DIR/scripts/ssh/status.sh"
    bash "$INSTALL_DIR/scripts/ssh/status.sh"
}

install_dotfiles() {
    local configs_dir="$INSTALL_DIR/configs"
    
    if [[ ! -d "$configs_dir" ]]; then
        log_warning "配置文件目录不存在"
        return
    fi
    
    log_info "安装配置文件..."
    
    for config in "$configs_dir"/.*; do
        [[ -f "$config" ]] || continue
        local filename=$(basename "$config")
        local target="$HOME/$filename"
        
        if [[ -f "$target" ]]; then
            log_warning "$filename 已存在，备份为 ${filename}.bak"
            cp "$target" "${target}.bak"
        fi
        
        cp "$config" "$target"
        log_success "已安装 $filename"
    done
}

list_scripts() {
    echo ""
    echo -e "${CYAN}可用脚本:${NC}"
    echo ""
    echo -e "  ${YELLOW}安装脚本:${NC}"
    for script in "$INSTALL_DIR/scripts/install/"*.sh; do
        [[ -f "$script" ]] || continue
        local name=$(basename "$script" .sh)
        echo -e "    ${GREEN}$name${NC}"
    done
    echo ""
    echo -e "  ${YELLOW}SSH 脚本:${NC}"
    for script in "$INSTALL_DIR/scripts/ssh/"*.sh; do
        [[ -f "$script" ]] || continue
        local name=$(basename "$script" .sh)
        echo -e "    ${GREEN}$name${NC}"
    done
    echo ""
}

#===============================================================================
# 主程序
#===============================================================================

main() {
    print_header "开发环境安装工具"
    
    # 检测系统
    log_info "检测到系统: $OS"
    
    # 检查依赖
    check_dependencies
    
    # 如果是远程执行，先克隆仓库
    if [[ ! -d "$INSTALL_DIR" ]] && [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
        setup_repo
    fi
    
    # 如果本地已有仓库，使用本地路径
    if [[ -f "./scripts/install/dev-tools.sh" ]]; then
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
                run_ssh_status
                ;;
            4)
                install_dotfiles
                ;;
            5)
                list_scripts
                ;;
            q|Q)
                log_info "已退出"
                exit 0
                ;;
            *)
                log_error "无效选项，请重新输入"
                ;;
        esac
    done
    
    echo ""
    log_success "操作完成！"
}

# 支持直接运行或通过 curl 管道执行
main "$@"
