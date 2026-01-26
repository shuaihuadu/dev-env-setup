# ~/.bashrc - Bash 配置文件
# 由 dev-env-setup 生成

#===============================================================================
# 基础设置
#===============================================================================

# 如果不是交互式 shell，则退出
case $- in
    *i*) ;;
      *) return;;
esac

# 历史记录设置
HISTCONTROL=ignoreboth
HISTSIZE=10000
HISTFILESIZE=20000
shopt -s histappend

# 窗口大小自动调整
shopt -s checkwinsize

#===============================================================================
# 颜色和提示符
#===============================================================================

# 启用颜色支持
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
fi

# 彩色提示符
parse_git_branch() {
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}

PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[33m\]$(parse_git_branch)\[\033[00m\]\$ '

#===============================================================================
# 别名
#===============================================================================

# 颜色支持 (macOS/Linux 兼容)
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
# 补全和其他
#===============================================================================

# Bash 补全
if ! shopt -oq posix; then
    if [ -f /usr/share/bash-completion/bash_completion ]; then
        . /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]; then
        . /etc/bash_completion
    fi
fi

# 加载本地配置
if [ -f ~/.bashrc.local ]; then
    . ~/.bashrc.local
fi
