# ~/.zshrc - Zsh 配置文件
# 由 dev-env-setup 生成

#===============================================================================
# 基础设置
#===============================================================================

# 历史记录设置
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=20000
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt APPEND_HISTORY
setopt SHARE_HISTORY

# 目录导航
setopt AUTO_CD
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS

# 补全系统
autoload -Uz compinit && compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

#===============================================================================
# 颜色和提示符
#===============================================================================

# 启用颜色
autoload -Uz colors && colors

# Git 分支显示
autoload -Uz vcs_info
precmd() { vcs_info }
zstyle ':vcs_info:git:*' formats ' (%F{yellow}%b%f)'
zstyle ':vcs_info:*' enable git
setopt PROMPT_SUBST

# 彩色提示符 (两行显示，带完整日期时间)
PROMPT='%F{cyan}╭─%f %F{green}%n@%m%f %F{blue}%~%f${vcs_info_msg_0_} %F{244}[%D{%Y-%m-%d %H:%M:%S}]%f
%F{cyan}╰─%f %F{magenta}➜%f '

#===============================================================================
# 别名
#===============================================================================

# 颜色支持 (macOS 兼容)
if [[ "$OSTYPE" == "darwin"* ]]; then
    alias ls='ls -G'
else
    alias ls='ls --color=auto'
fi
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# 常用 ls 别名
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# 安全别名
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# 目录导航
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Git 别名
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git pull'
alias gd='git diff'
alias glog='git log --oneline --graph --decorate'

# Docker 别名
alias dk='docker'
alias dkc='docker-compose'
alias dkps='docker ps'
alias dkimg='docker images'

# Kubernetes 别名
alias k='kubectl'
alias kgp='kubectl get pods'
alias kgs='kubectl get svc'
alias kgd='kubectl get deployments'
alias kga='kubectl get all'
alias kaf='kubectl apply -f'
alias kdel='kubectl delete'
alias klog='kubectl logs'
alias kexec='kubectl exec -it'

# 系统信息
alias ports='netstat -tulanp'
alias meminfo='free -h'
alias diskinfo='df -h'

#===============================================================================
# 环境变量
#===============================================================================

# 编辑器
export EDITOR=vim
export VISUAL=vim

# 语言环境
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# PATH 扩展
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/bin:$PATH"

#===============================================================================
# 开发环境
#===============================================================================

# nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Go
export GOPATH="$HOME/go"
export PATH="$PATH:$GOPATH/bin"

# Rust
[ -f "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"

# Bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

#===============================================================================
# 函数
#===============================================================================

# 创建目录并进入
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# 解压任意格式
extract() {
    if [ -f "$1" ]; then
        case "$1" in
            *.tar.bz2)   tar xjf "$1"   ;;
            *.tar.gz)    tar xzf "$1"   ;;
            *.tar.xz)    tar xJf "$1"   ;;
            *.bz2)       bunzip2 "$1"   ;;
            *.rar)       unrar x "$1"   ;;
            *.gz)        gunzip "$1"    ;;
            *.tar)       tar xf "$1"    ;;
            *.tbz2)      tar xjf "$1"   ;;
            *.tgz)       tar xzf "$1"   ;;
            *.zip)       unzip "$1"     ;;
            *.Z)         uncompress "$1";;
            *.7z)        7z x "$1"      ;;
            *)           echo "'$1' 无法解压" ;;
        esac
    else
        echo "'$1' 不是有效文件"
    fi
}

# 快速查找文件
ff() {
    find . -type f -name "*$1*"
}

# 快速查找目录
fd() {
    find . -type d -name "*$1*"
}

#===============================================================================
# 插件和扩展
#===============================================================================

# Oh My Zsh (如果安装了)
if [ -d "$HOME/.oh-my-zsh" ]; then
    export ZSH="$HOME/.oh-my-zsh"
    ZSH_THEME=""  # 使用自定义提示符
    plugins=(git docker kubectl macos colored-man-pages)
    source $ZSH/oh-my-zsh.sh
fi

# zsh-autosuggestions (如果通过 Homebrew 安装)
if [ -f /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
    source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

# zsh-syntax-highlighting (如果通过 Homebrew 安装，必须放在最后)
if [ -f /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
    source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

# 加载本地配置
if [ -f ~/.zshrc.local ]; then
    source ~/.zshrc.local
fi
