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

.PHONY: help setup tools ssh-port install dotfiles list clean

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

tools: ## 安装全部开发工具 (前端/后台/数据库/云)
	@echo -e "$(CYAN)安装开发工具...$(NC)"
	@sudo bash $(SCRIPTS_DIR)/install-dev-tools.sh

ssh-port: ## 修改 SSH 端口
	@echo -e "$(CYAN)运行 SSH 端口修改工具...$(NC)"
	@sudo bash $(SCRIPTS_DIR)/change-ssh-port.sh

#===============================================================================
# 安装命令
#===============================================================================

install: ## 将脚本安装到 /usr/local/bin
	@echo -e "$(CYAN)安装脚本到 /usr/local/bin...$(NC)"
	@sudo install -m 755 $(SCRIPTS_DIR)/change-ssh-port.sh /usr/local/bin/change-ssh-port
	@sudo install -m 755 $(SCRIPTS_DIR)/install-dev-tools.sh /usr/local/bin/install-dev-tools
	@echo -e "$(GREEN)安装完成！$(NC)"
	@echo "  - change-ssh-port"
	@echo "  - install-dev-tools"

uninstall: ## 从 /usr/local/bin 卸载脚本
	@echo -e "$(YELLOW)卸载脚本...$(NC)"
	@sudo rm -f /usr/local/bin/change-ssh-port
	@sudo rm -f /usr/local/bin/install-dev-tools
	@echo -e "$(GREEN)卸载完成！$(NC)"

#===============================================================================
# 配置文件
#===============================================================================

dotfiles: ## 安装配置文件 (dotfiles) 到 $HOME
	@echo -e "$(CYAN)安装配置文件...$(NC)"
	@for config in $(CONFIGS_DIR)/.*; do \
		if [ -f "$$config" ]; then \
			filename=$$(basename "$$config"); \
			if [ -f "$$HOME/$$filename" ]; then \
				echo -e "  $(YELLOW)备份$$filename$(NC)"; \
				cp "$$HOME/$$filename" "$$HOME/$$filename.bak"; \
			fi; \
			cp "$$config" "$$HOME/$$filename"; \
			echo -e "  $(GREEN)已安装 $$filename$(NC)"; \
		fi; \
	done
	@echo -e "$(GREEN)配置文件安装完成！$(NC)"

#===============================================================================
# 工具命令
#===============================================================================

list: ## 列出所有可用脚本
	@echo -e "$(CYAN)可用脚本:$(NC)"
	@echo ""
	@ls -la $(SCRIPTS_DIR)/*.sh 2>/dev/null || echo "  没有找到脚本"
	@echo ""

check: ## 检查脚本语法
	@echo -e "$(CYAN)检查脚本语法...$(NC)"
	@for script in $(SCRIPTS_DIR)/*.sh; do \
		echo -n "  $$script: "; \
		if bash -n "$$script" 2>/dev/null; then \
			echo -e "$(GREEN)OK$(NC)"; \
		else \
			echo -e "$(YELLOW)ERROR$(NC)"; \
		fi; \
	done

clean: ## 清理临时文件
	@echo -e "$(CYAN)清理临时文件...$(NC)"
	@find . -name "*.bak" -delete 2>/dev/null || true
	@find . -name "*~" -delete 2>/dev/null || true
	@echo -e "$(GREEN)清理完成！$(NC)"
