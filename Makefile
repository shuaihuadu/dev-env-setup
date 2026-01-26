# Dev Environment Setup - Makefile
# ================================

SHELL := /bin/bash
SCRIPTS_DIR := scripts
CONFIGS_DIR := configs

# 默认目标
.DEFAULT_GOAL := help

# 颜色定义
CYAN := \033[0;36m
GREEN := \033[0;32m
YELLOW := \033[1;33m
NC := \033[0m

.PHONY: help setup install-tools ssh-port ssh-status dotfiles list clean

#===============================================================================
# 帮助信息
#===============================================================================

help: ## 显示帮助信息
	@echo ""
	@echo -e "$(CYAN)Dev Environment Setup$(NC)"
	@echo -e "$(CYAN)=====================$(NC)"
	@echo ""
	@echo "可用命令:"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-15s$(NC) %s\n", $$1, $$2}'
	@echo ""

#===============================================================================
# 主要命令
#===============================================================================

install-tools: ## 安装开发工具（已安装的自动跳过）
	@echo -e "$(CYAN)安装开发工具...$(NC)"
	@chmod +x $(SCRIPTS_DIR)/install/dev-tools.sh
	@chmod +x $(SCRIPTS_DIR)/lib/common.sh
	@sudo bash $(SCRIPTS_DIR)/install/dev-tools.sh

ssh-port: ## 修改 SSH 端口
	@echo -e "$(CYAN)运行 SSH 端口修改工具...$(NC)"
	@chmod +x $(SCRIPTS_DIR)/ssh/change-port.sh
	@chmod +x $(SCRIPTS_DIR)/lib/common.sh
	@sudo bash $(SCRIPTS_DIR)/ssh/change-port.sh

ssh-status: ## 查看当前 SSH 端口状态
	@chmod +x $(SCRIPTS_DIR)/ssh/status.sh
	@chmod +x $(SCRIPTS_DIR)/lib/common.sh
	@bash $(SCRIPTS_DIR)/ssh/status.sh

#===============================================================================
# 配置文件
#===============================================================================

dotfiles: ## 安装配置文件 (dotfiles) 到 $HOME
	@echo -e "$(CYAN)安装配置文件...$(NC)"
	@echo ""
	@for config in $(CONFIGS_DIR)/.*; do \
		if [ -f "$$config" ]; then \
			filename=$$(basename "$$config"); \
			read -p "是否安装 $$filename? (输入 yes 安装，其他跳过): " reply; \
			echo ""; \
			if [[ "$$reply" == "yes" ]] || [[ "$$reply" == "y" ]]; then \
				if [ "$$filename" = ".gitconfig" ]; then \
					read -p "  请输入 Git 用户名: " git_name; \
					read -p "  请输入 Git 邮箱: " git_email; \
					if [ -n "$$git_name" ] && [ -n "$$git_email" ]; then \
						if [ -f "$$HOME/$$filename" ]; then \
							echo -e "  $(YELLOW)备份 $$filename$(NC)"; \
							cp "$$HOME/$$filename" "$$HOME/$$filename.bak"; \
						fi; \
						sed -e "s/YOUR_NAME/$$git_name/g" \
						    -e "s/YOUR_EMAIL@example.com/$$git_email/g" \
						    "$$config" > "$$HOME/$$filename"; \
						echo -e "  $(GREEN)✓ 已安装 $$filename (已配置用户信息)$(NC)"; \
					else \
						echo -e "  $(YELLOW)⊘ 跳过 $$filename (未提供用户信息)$(NC)"; \
					fi; \
				else \
					if [ -f "$$HOME/$$filename" ]; then \
						echo -e "  $(YELLOW)备份 $$filename$(NC)"; \
						cp "$$HOME/$$filename" "$$HOME/$$filename.bak"; \
					fi; \
					cp "$$config" "$$HOME/$$filename"; \
					echo -e "  $(GREEN)✓ 已安装 $$filename$(NC)"; \
				fi; \
			else \
				echo -e "  $(YELLOW)⊘ 跳过 $$filename$(NC)"; \
			fi; \
			echo ""; \
		fi; \
	done
	@echo -e "$(GREEN)配置文件安装完成！$(NC)"

set-terminal-theme: ## 选择并设置 Oh My Zsh 主题
	@echo -e "$(CYAN)Oh My Zsh 主题选择器$(NC)"
	@echo ""
	@# 检查 Oh My Zsh 是否安装
	@if [ ! -d "$$HOME/.oh-my-zsh" ]; then \
		echo -e "$(YELLOW)⚠ Oh My Zsh 未安装$(NC)"; \
		echo ""; \
		read -p "是否现在安装 Oh My Zsh？(输入 yes 安装): " install_omz; \
		if [[ "$$install_omz" == "yes" ]] || [[ "$$install_omz" == "y" ]]; then \
			echo ""; \
			echo -e "$(CYAN)正在安装 Oh My Zsh...$(NC)"; \
			sh -c "$$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended; \
			if [ -d "$$HOME/.oh-my-zsh" ]; then \
				echo ""; \
				echo -e "$(GREEN)✓ Oh My Zsh 安装成功！$(NC)"; \
				echo ""; \
			else \
				echo ""; \
				echo -e "$(YELLOW)⚠ Oh My Zsh 安装失败$(NC)"; \
				echo "请手动安装: sh -c \"\$$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)\""; \
				exit 1; \
			fi; \
		else \
			echo ""; \
			echo -e "$(YELLOW)⊘ 已取消，你可以继续使用当前的自定义提示符$(NC)"; \
			exit 0; \
		fi; \
	fi
	@echo -e "$(GREEN)✓ Oh My Zsh 已安装$(NC)"
	@echo ""
	@echo -e "$(YELLOW)推荐主题：$(NC)"
	@echo "  1. robbyrussell  - 默认主题，简洁快速"
	@echo "  2. agnoster      - Powerline 风格（需要特殊字体）"
	@echo "  3. avit          - 简洁实用，带时间戳"
	@echo "  4. bira          - 双行显示，清晰布局"
	@echo "  5. gnzh          - 紧凑信息丰富"
	@echo "  6. ys            - 干净现代"
	@echo "  7. bureau        - 专业风格，带 Git 和 Node 信息"
	@echo "  8. candy         - 彩色活泼"
	@echo "  9. clean         - 极简风格"
	@echo " 10. random        - 每次启动随机主题"
	@echo ""
	@echo -e "$(YELLOW)更多主题查看：$(NC) https://github.com/ohmyzsh/ohmyzsh/wiki/Themes"
	@echo ""
	@read -p "请输入主题名称（或直接回车跳过）: " theme_name; \
	if [ -n "$$theme_name" ]; then \
		echo ""; \
		read -p "确认将主题设置为 '$$theme_name'？(输入 yes 确认): " confirm; \
		if [[ "$$confirm" == "yes" ]] || [[ "$$confirm" == "y" ]]; then \
			if [ -f "$$HOME/.zshrc" ]; then \
				if grep -q "^ZSH_THEME=" "$$HOME/.zshrc"; then \
					current_theme=$$(grep "^ZSH_THEME=" "$$HOME/.zshrc" | cut -d'"' -f2); \
					echo -e "  $(YELLOW)当前主题: $$current_theme$(NC)"; \
					cp "$$HOME/.zshrc" "$$HOME/.zshrc.bak" || { echo -e "  $(YELLOW)⚠ 备份失败$(NC)"; exit 1; }; \
					if [[ "$$OSTYPE" == "darwin"* ]]; then \
						sed -i '' "s/^ZSH_THEME=.*/ZSH_THEME=\"$$theme_name\"/" "$$HOME/.zshrc"; \
					else \
						sed -i "s/^ZSH_THEME=.*/ZSH_THEME=\"$$theme_name\"/" "$$HOME/.zshrc"; \
					fi; \
					if [ $$? -eq 0 ] && grep -q "^ZSH_THEME=\"$$theme_name\"" "$$HOME/.zshrc"; then \
						echo -e "  $(GREEN)✓ 主题已更新为: $$theme_name$(NC)"; \
						echo -e "  $(YELLOW)提示：运行 'source ~/.zshrc' 或重新打开终端生效$(NC)"; \
						echo -e "  $(YELLOW)备份文件：~/.zshrc.bak（如需恢复运行：cp ~/.zshrc.bak ~/.zshrc）$(NC)"; \
					else \
						echo -e "  $(YELLOW)⚠ 设置失败，正在恢复...$(NC)"; \
						cp "$$HOME/.zshrc.bak" "$$HOME/.zshrc" && echo -e "  $(GREEN)✓ 已从备份恢复$(NC)" || echo -e "  $(YELLOW)⚠ 恢复失败，请手动执行：cp ~/.zshrc.bak ~/.zshrc$(NC)"; \
					fi; \
				else \
					cp "$$HOME/.zshrc" "$$HOME/.zshrc.bak" 2>/dev/null; \
					echo 'ZSH_THEME="'$$theme_name'"' >> "$$HOME/.zshrc"; \
					if [ $$? -eq 0 ]; then \
						echo -e "  $(GREEN)✓ 主题已添加: $$theme_name$(NC)"; \
						echo -e "  $(YELLOW)提示：运行 'source ~/.zshrc' 或重新打开终端生效$(NC)"; \
					else \
						echo -e "  $(YELLOW)⚠ 添加主题失败$(NC)"; \
					fi; \
				fi; \
			else \
				echo -e "  $(YELLOW)⚠ 未找到 ~/.zshrc 文件$(NC)"; \
				echo -e "  $(YELLOW)请先运行 'make dotfiles' 安装配置文件$(NC)"; \
			fi; \
		else \
			echo -e "  $(YELLOW)⊘ 已取消设置$(NC)"; \
		fi; \
	else \
		echo -e "  $(YELLOW)⊘ 已取消$(NC)"; \
	fi

restore-terminal-to-default: ## 根据系统恢复默认终端配置 (macOS→zsh, Linux→bash)
	@echo -e "$(CYAN)恢复默认终端配置$(NC)"
	@echo ""
	@# 根据操作系统确定配置文件
	@if [[ "$$OSTYPE" == "darwin"* ]]; then \
		config_file=".zshrc"; \
		shell_name="zsh"; \
	else \
		config_file=".bashrc"; \
		shell_name="bash"; \
	fi; \
	echo -e "$(YELLOW)检测到系统: $$(uname -s)$(NC)"; \
	echo -e "$(YELLOW)将恢复: $$config_file ($$shell_name)$(NC)"; \
	echo ""; \
	if [ ! -f "$(CONFIGS_DIR)/$$config_file" ]; then \
		echo -e "$(YELLOW)⚠ 未找到默认配置文件: $(CONFIGS_DIR)/$$config_file$(NC)"; \
		exit 1; \
	fi; \
	if [ -f "$$HOME/$$config_file" ]; then \
		echo -e "$(YELLOW)当前 $$config_file 配置将被替换$(NC)"; \
		if [ "$$config_file" = ".zshrc" ] && grep -q "^ZSH_THEME=" "$$HOME/$$config_file"; then \
			current_theme=$$(grep "^ZSH_THEME=" "$$HOME/$$config_file" | cut -d'"' -f2); \
			echo -e "  当前主题: $$current_theme"; \
		fi; \
		echo ""; \
		read -p "确认恢复到默认配置？(输入 yes 确认): " confirm; \
		if [[ "$$confirm" == "yes" ]] || [[ "$$confirm" == "y" ]]; then \
			backup_file="$$HOME/$$config_file.backup.$$(date +%Y%m%d_%H%M%S)"; \
			cp "$$HOME/$$config_file" "$$backup_file"; \
			echo ""; \
			echo -e "  $(GREEN)✓ 已备份当前配置到: $$backup_file$(NC)"; \
			cp "$(CONFIGS_DIR)/$$config_file" "$$HOME/$$config_file"; \
			if [ $$? -eq 0 ]; then \
				echo -e "  $(GREEN)✓ 已恢复默认配置 ($$config_file)$(NC)"; \
				echo -e "  $(YELLOW)提示：运行 'source ~/$$config_file' 或重新打开终端生效$(NC)"; \
			else \
				echo -e "  $(YELLOW)⚠ 恢复失败，正在从备份还原...$(NC)"; \
				cp "$$backup_file" "$$HOME/$$config_file" && echo -e "  $(GREEN)✓ 已还原$(NC)"; \
			fi; \
		else \
			echo ""; \
			echo -e "  $(YELLOW)⊘ 已取消恢复$(NC)"; \
		fi; \
	else \
		echo -e "$(YELLOW)未找到 ~/$$config_file 文件，将直接安装默认配置$(NC)"; \
		echo ""; \
		read -p "确认安装默认配置？(输入 yes 确认): " confirm; \
		if [[ "$$confirm" == "yes" ]] || [[ "$$confirm" == "y" ]]; then \
			cp "$(CONFIGS_DIR)/$$config_file" "$$HOME/$$config_file"; \
			echo ""; \
			echo -e "  $(GREEN)✓ 已安装默认配置 ($$config_file)$(NC)"; \
			echo -e "  $(YELLOW)提示：运行 'source ~/$$config_file' 或重新打开终端生效$(NC)"; \
		else \
			echo ""; \
			echo -e "  $(YELLOW)⊘ 已取消$(NC)"; \
		fi; \
	fi

#===============================================================================
# 工具命令
#===============================================================================

list: ## 列出所有可用脚本
	@echo -e "$(CYAN)可用脚本:$(NC)"
	@echo ""
	@echo -e "  $(YELLOW)安装脚本:$(NC)"
	@ls -la $(SCRIPTS_DIR)/install/*.sh 2>/dev/null || echo "    没有找到脚本"
	@echo ""
	@echo -e "  $(YELLOW)SSH 脚本:$(NC)"
	@ls -la $(SCRIPTS_DIR)/ssh/*.sh 2>/dev/null || echo "    没有找到脚本"
	@echo ""
	@echo -e "  $(YELLOW)公共库:$(NC)"
	@ls -la $(SCRIPTS_DIR)/lib/*.sh 2>/dev/null || echo "    没有找到脚本"
	@echo ""

check: ## 检查脚本语法
	@echo -e "$(CYAN)检查脚本语法...$(NC)"
	@for script in $(SCRIPTS_DIR)/lib/*.sh $(SCRIPTS_DIR)/install/*.sh $(SCRIPTS_DIR)/ssh/*.sh; do \
		if [ -f "$$script" ]; then \
			echo -n "  $$script: "; \
			if bash -n "$$script" 2>/dev/null; then \
				echo -e "$(GREEN)OK$(NC)"; \
			else \
				echo -e "$(YELLOW)ERROR$(NC)"; \
			fi; \
		fi; \
	done

clean: ## 清理临时文件
	@echo -e "$(CYAN)清理临时文件...$(NC)"
	@find . -name "*.bak" -delete 2>/dev/null || true
	@find . -name "*~" -delete 2>/dev/null || true
	@echo -e "$(GREEN)清理完成！$(NC)"
