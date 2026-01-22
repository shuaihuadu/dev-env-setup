#!/bin/bash

#===============================================================================
# SSH 端口状态查看脚本
#===============================================================================

# 获取脚本目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 加载公共函数库
source "$SCRIPT_DIR/../lib/common.sh"

#===============================================================================
# 获取当前 SSH 端口
#===============================================================================

get_ssh_port() {
    local port=""
    
    # 优先从 systemd socket 获取端口
    if [ -f /etc/systemd/system/ssh.socket.d/override.conf ]; then
        port=$(grep -E "^ListenStream=.*:[0-9]+" /etc/systemd/system/ssh.socket.d/override.conf 2>/dev/null | head -1 | grep -oE "[0-9]+$")
    fi
    
    # 如果 socket 没有配置，从 sshd_config 获取
    if [ -z "$port" ]; then
        port=$(grep -E "^Port" /etc/ssh/sshd_config 2>/dev/null | awk '{print $2}')
    fi
    
    # 默认端口
    if [ -z "$port" ]; then
        port="22"
    fi
    
    echo "$port"
}

#===============================================================================
# 显示 SSH 状态
#===============================================================================

show_status() {
    local current_port=$(get_ssh_port)
    
    print_box_start
    echo -e "${CYAN}                    SSH 端口状态${NC}"
    print_box_end
    
    echo -e "  ${GREEN}★ 当前 SSH 端口: ${current_port}${NC}"
    echo ""
    echo -e "  连接命令: ssh -p ${current_port} user@hostname"
    echo ""
    
    print_divider
    echo -e "  配置详情:"
    print_divider
    echo ""
    
    # sshd_config 配置
    echo -e "  ${YELLOW}sshd_config:${NC}"
    local port_cfg=$(grep -E "^Port" /etc/ssh/sshd_config 2>/dev/null)
    if [ -n "$port_cfg" ]; then
        echo "    $port_cfg"
    else
        echo -e "    ${YELLOW}未设置 (默认 22，但可能被 socket 覆盖)${NC}"
    fi
    echo ""
    
    # Systemd Socket 配置
    echo -e "  ${YELLOW}Systemd Socket (优先级更高):${NC}"
    if [ -f /etc/systemd/system/ssh.socket.d/override.conf ]; then
        local socket_port=$(grep -E "^ListenStream=.*:[0-9]+" /etc/systemd/system/ssh.socket.d/override.conf 2>/dev/null | head -1 | grep -oE "[0-9]+$")
        echo -e "    ${GREEN}已配置，端口: ${socket_port}${NC}"
    else
        echo "    未配置"
    fi
    echo ""
    
    print_box_start
}

#===============================================================================
# 主程序
#===============================================================================

# 如果直接运行此脚本
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    show_status
fi
