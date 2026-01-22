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
