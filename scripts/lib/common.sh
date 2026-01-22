#!/bin/bash

#===============================================================================
# 公共函数库
# 提供颜色输出、日志、系统检测等公共功能
#===============================================================================

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

#===============================================================================
# 日志函数
#===============================================================================

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_skip() {
    echo -e "${YELLOW}[SKIP]${NC} 已安装 $1 (版本: $2)，跳过安装"
}

#===============================================================================
# 输出格式化
#===============================================================================

print_header() {
    local title=$1
    local width=64
    # 计算显示宽度（中文字符占2个宽度）
    local display_width=$(echo -n "$title" | wc -m)
    local chinese_chars=$(echo -n "$title" | grep -oP '[\x{4e00}-\x{9fff}]' 2>/dev/null | wc -l || echo 0)
    local title_width=$((display_width + chinese_chars))
    local pad_left=$(( (width - title_width) / 2 ))
    local pad_right=$(( width - title_width - pad_left ))
    
    echo -e "${CYAN}"
    echo "╔════════════════════════════════════════════════════════════════╗"
    printf "║%${pad_left}s%s%${pad_right}s║\n" "" "$title" ""
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

print_section() {
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}  $1${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

print_divider() {
    echo -e "${CYAN}────────────────────────────────────────────────────────────────${NC}"
}

print_box_start() {
    echo ""
    echo -e "${CYAN}════════════════════════════════════════════════════════════════${NC}"
}

print_box_end() {
    echo -e "${CYAN}════════════════════════════════════════════════════════════════${NC}"
    echo ""
}

#===============================================================================
# 系统检测
#===============================================================================

# 检测操作系统
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

# 检查命令是否存在
command_exists() {
    command -v "$1" &> /dev/null
}

# 检查是否为 root 用户
check_root() {
    if [[ $EUID -ne 0 ]]; then
        log_error "此脚本需要 root 权限运行"
        log_info "请使用: sudo $0"
        exit 1
    fi
}

# 检查是否需要 sudo
need_sudo() {
    if [[ $EUID -ne 0 ]]; then
        log_warning "部分操作需要 sudo 权限"
    fi
}

#===============================================================================
# 包管理器
#===============================================================================

# 更新包管理器
update_package_manager() {
    local os=$(detect_os)
    case $os in
        ubuntu|debian)
            sudo apt-get update -qq
            ;;
        centos|rhel|fedora)
            sudo yum check-update || true
            ;;
        macos)
            brew update
            ;;
    esac
}

# 安装包
install_package() {
    local package=$1
    local os=$(detect_os)
    case $os in
        ubuntu|debian)
            sudo apt-get install -y "$package"
            ;;
        centos|rhel|fedora)
            sudo yum install -y "$package"
            ;;
        macos)
            brew install "$package"
            ;;
    esac
}

#===============================================================================
# 导出变量供子脚本使用
#===============================================================================

export RED GREEN YELLOW BLUE CYAN NC
