#!/bin/bash

#===============================================================================
# SSH 端口修改脚本
# 功能：安全地修改 SSH 服务端口
# 支持：Ubuntu 22.04/24.04 (systemd socket 激活模式)
#===============================================================================

set -e

# 获取脚本目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 加载公共函数库
source "$SCRIPT_DIR/../lib/common.sh"

# SSH 配置文件路径
SSHD_CONFIG="/etc/ssh/sshd_config"
BACKUP_SUFFIX=".backup.$(date +%Y%m%d_%H%M%S)"

#===============================================================================
# 函数定义
#===============================================================================

# 检查 SSH 配置文件是否存在
check_sshd_config() {
    if [[ ! -f "$SSHD_CONFIG" ]]; then
        log_error "SSH 配置文件不存在: $SSHD_CONFIG"
        exit 1
    fi
}

# 获取当前 SSH 端口
get_current_port() {
    local port
    
    # 优先从 systemd socket 获取端口
    if systemctl is-active ssh.socket &>/dev/null || [ -f /etc/systemd/system/ssh.socket.d/override.conf ]; then
        port=$(grep -E "^ListenStream=.*:[0-9]+" /etc/systemd/system/ssh.socket.d/override.conf 2>/dev/null | head -1 | grep -oE "[0-9]+$")
        if [[ -n "$port" ]]; then
            echo "$port"
            return
        fi
    fi
    
    # 从 sshd_config 获取
    port=$(grep -E "^Port\s+" "$SSHD_CONFIG" 2>/dev/null | awk '{print $2}' | head -1)
    if [[ -z "$port" ]]; then
        port="22"
    fi
    echo "$port"
}

# 验证端口号是否有效
validate_port() {
    local port=$1
    
    # 检查是否为数字
    if ! [[ "$port" =~ ^[0-9]+$ ]]; then
        log_error "端口必须是数字"
        return 1
    fi
    
    # 检查端口范围
    if [[ "$port" -lt 1 || "$port" -gt 65535 ]]; then
        log_error "端口必须在 1-65535 范围内"
        return 1
    fi
    
    # 警告使用特权端口
    if [[ "$port" -lt 1024 && "$port" -ne 22 ]]; then
        log_warning "端口 $port 是特权端口 (<1024)，需要 root 权限"
    fi
    
    return 0
}

# 检查端口是否被占用
check_port_in_use() {
    local port=$1
    local current_port
    current_port=$(get_current_port)
    
    # 如果是当前 SSH 端口，跳过检查
    if [[ "$port" == "$current_port" ]]; then
        return 0
    fi
    
    if ss -tuln 2>/dev/null | grep -q ":${port}\s"; then
        log_warning "端口 $port 当前可能被其他服务占用"
        read -p "是否继续? (y/N): " continue_anyway
        if [[ ! "$continue_anyway" =~ ^[Yy]$ ]]; then
            return 1
        fi
    fi
    return 0
}

# 备份配置文件
backup_config() {
    local backup_file="${SSHD_CONFIG}${BACKUP_SUFFIX}"
    cp "$SSHD_CONFIG" "$backup_file"
    log_success "配置文件已备份到: $backup_file"
}

# 修改 SSH 端口
change_ssh_port() {
    local new_port=$1
    
    # 检查是否存在 Port 配置行
    if grep -qE "^#?\s*Port\s+" "$SSHD_CONFIG"; then
        # 替换现有配置（包括被注释的）
        sed -i -E "s/^#?\s*Port\s+.*/Port $new_port/" "$SSHD_CONFIG"
    else
        # 添加新的端口配置
        echo "Port $new_port" >> "$SSHD_CONFIG"
    fi
}

# 验证 SSH 配置语法
validate_ssh_config() {
    log_info "验证 SSH 配置语法..."
    if sshd -t 2>/dev/null; then
        log_success "SSH 配置语法正确"
        return 0
    else
        log_error "SSH 配置语法错误"
        sshd -t
        return 1
    fi
}

# 配置 systemd socket (Ubuntu 22.04/24.04)
configure_systemd_socket() {
    local port=$1
    local socket_override_dir="/etc/systemd/system/ssh.socket.d"
    local socket_override_file="$socket_override_dir/override.conf"
    
    # 检查是否使用 systemd socket 激活
    if systemctl is-active ssh.socket &>/dev/null || [ -f /lib/systemd/system/ssh.socket ]; then
        log_info "检测到 systemd socket 激活模式，配置 ssh.socket..."
        
        # 创建 override 目录
        mkdir -p "$socket_override_dir"
        
        # 创建 override 配置
        cat > "$socket_override_file" << EOF
[Socket]
ListenStream=
ListenStream=0.0.0.0:$port
ListenStream=[::]:$port
EOF
        
        log_success "已创建 socket 覆盖配置: $socket_override_file"
        
        # 重新加载 systemd 配置
        systemctl daemon-reload
        
        return 0
    fi
    
    return 1
}

# 重启 SSH 服务
restart_ssh_service() {
    local port=$1
    log_info "正在重启 SSH 服务..."
    
    # 检测系统使用的 init 系统
    if command -v systemctl &> /dev/null; then
        # 检查是否使用 socket 激活
        if systemctl is-active ssh.socket &>/dev/null || systemctl is-enabled ssh.socket &>/dev/null 2>/dev/null; then
            # 配置并重启 socket
            configure_systemd_socket "$port"
            systemctl stop ssh.socket 2>/dev/null
            systemctl stop ssh.service 2>/dev/null || systemctl stop sshd.service 2>/dev/null
            systemctl start ssh.socket 2>/dev/null
        else
            # 传统方式重启服务
            systemctl restart sshd 2>/dev/null || systemctl restart ssh 2>/dev/null
        fi
    elif command -v service &> /dev/null; then
        service sshd restart 2>/dev/null || service ssh restart 2>/dev/null
    else
        log_error "无法确定如何重启 SSH 服务"
        return 1
    fi
    
    sleep 2
    log_success "SSH 服务已重启"
}

# 验证新端口是否生效
verify_port_change() {
    local expected_port=$1
    
    log_info "验证端口更改..."
    
    # 检查监听的端口
    if ss -tlnp 2>/dev/null | grep -qE ":${expected_port}\s"; then
        log_success "验证成功：SSH 正在监听端口 $expected_port"
        return 0
    else
        log_warning "无法确认端口更改，请手动检查"
        return 1
    fi
}

# 配置防火墙
configure_firewall() {
    local port=$1
    
    log_info "检查防火墙配置..."
    
    # 检测并配置 UFW
    if command -v ufw &> /dev/null && ufw status 2>/dev/null | grep -q "Status: active"; then
        log_info "检测到 UFW 防火墙"
        read -p "是否自动配置 UFW 允许端口 $port? (Y/n): " configure_ufw
        if [[ ! "$configure_ufw" =~ ^[Nn]$ ]]; then
            ufw allow "$port"/tcp
            log_success "已添加 UFW 规则：允许端口 $port"
        fi
    fi
    
    # 检测并配置 firewalld
    if command -v firewall-cmd &> /dev/null && systemctl is-active firewalld &> /dev/null; then
        log_info "检测到 firewalld 防火墙"
        read -p "是否自动配置 firewalld 允许端口 $port? (Y/n): " configure_firewalld
        if [[ ! "$configure_firewalld" =~ ^[Nn]$ ]]; then
            firewall-cmd --permanent --add-port="$port"/tcp
            firewall-cmd --reload
            log_success "已添加 firewalld 规则：允许端口 $port"
        fi
    fi
}

# 显示端口选择菜单
show_port_menu() {
    local current_port
    current_port=$(get_current_port)
    
    echo ""
    echo -e "${YELLOW}当前 SSH 端口: ${GREEN}$current_port${NC}"
    echo ""
    echo "请选择新的 SSH 端口:"
    echo "  1) 22     (默认端口)"
    echo "  2) 22389  (自定义高端口)"
    echo "  3) 其他   (手动输入)"
    echo "  q) 退出"
    echo ""
}

# 获取用户选择的端口
get_user_port_choice() {
    local choice
    local port
    
    while true; do
        read -p "请输入选项 [1/2/3/q]: " choice
        
        case $choice in
            1)
                port="22"
                break
                ;;
            2)
                port="22389"
                break
                ;;
            3)
                read -p "请输入自定义端口号 (1-65535): " port
                if validate_port "$port"; then
                    break
                fi
                ;;
            q|Q)
                log_info "已取消操作"
                exit 0
                ;;
            *)
                log_error "无效选项，请重新输入"
                ;;
        esac
    done
    
    echo "$port"
}

# 显示最终结果
show_result() {
    local new_port=$1
    
    print_box_start
    echo -e "${GREEN}修改完成！${NC}"
    print_box_end
    echo ""
    echo -e "  SSH 端口已更改为: ${GREEN}${new_port}${NC}"
    echo ""
    echo -e "  ${YELLOW}连接命令示例:${NC}"
    echo -e "    ssh -p $new_port user@hostname"
    echo ""
    echo -e "  ${YELLOW}重要提示:${NC}"
    echo -e "    - 当前连接不会断开"
    echo -e "    - 新连接需要使用端口 $new_port"
    echo -e "    - 配置备份位置: ${SSHD_CONFIG}${BACKUP_SUFFIX}"
    print_box_start
}

# 恢复备份
restore_backup() {
    local backup_file=$1
    
    if [[ -f "$backup_file" ]]; then
        cp "$backup_file" "$SSHD_CONFIG"
        restart_ssh_service "22"
        log_success "已恢复备份配置"
    else
        log_error "备份文件不存在: $backup_file"
    fi
}

#===============================================================================
# 主程序
#===============================================================================

main() {
    print_header "SSH 端口修改工具 v1.1"
    
    # 检查权限和配置文件
    check_root
    check_sshd_config
    
    # 显示菜单并获取用户选择
    show_port_menu
    new_port=$(get_user_port_choice)
    
    # 获取当前端口
    current_port=$(get_current_port)
    
    # 检查是否需要修改
    if [[ "$new_port" == "$current_port" ]]; then
        log_warning "新端口与当前端口相同 ($current_port)，无需修改"
        exit 0
    fi
    
    # 检查端口是否被占用
    if ! check_port_in_use "$new_port"; then
        exit 1
    fi
    
    # 确认修改
    echo ""
    echo -e "${YELLOW}确认信息:${NC}"
    echo -e "  当前端口: ${RED}$current_port${NC}"
    echo -e "  新端口:   ${GREEN}$new_port${NC}"
    echo ""
    read -p "确认修改 SSH 端口? (y/N): " confirm
    
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        log_info "已取消操作"
        exit 0
    fi
    
    # 执行修改
    echo ""
    log_info "开始修改 SSH 端口..."
    
    # 备份配置
    backup_config
    
    # 修改端口
    change_ssh_port "$new_port"
    log_success "端口配置已更新"
    
    # 验证配置语法
    if ! validate_ssh_config; then
        log_error "配置验证失败，正在恢复备份..."
        restore_backup "${SSHD_CONFIG}${BACKUP_SUFFIX}"
        exit 1
    fi
    
    # 配置防火墙
    configure_firewall "$new_port"
    
    # 重启 SSH 服务
    restart_ssh_service "$new_port"
    
    # 验证端口更改
    verify_port_change "$new_port"
    
    # 显示结果
    show_result "$new_port"
}

# 运行主程序
main "$@"
