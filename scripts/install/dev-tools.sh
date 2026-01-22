#!/bin/bash

#===============================================================================
# Dev Tools Installer - 开发工具安装脚本
# 功能：模块化安装前端、后台、数据库、云和通用开发工具
# 支持：Ubuntu/Debian, CentOS/RHEL, macOS
#===============================================================================

set -e

# 获取脚本目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 加载公共函数库
source "$SCRIPT_DIR/../lib/common.sh"

#===============================================================================
# 安装计数器
#===============================================================================

INSTALLED_COUNT=0
SKIPPED_COUNT=0
FAILED_COUNT=0
INSTALLED_TOOLS=()
SKIPPED_TOOLS=()
FAILED_TOOLS=()

# 记录安装成功
record_installed() {
    ((INSTALLED_COUNT++)) || true
    INSTALLED_TOOLS+=("$1")
}

# 记录跳过
record_skipped() {
    ((SKIPPED_COUNT++)) || true
    SKIPPED_TOOLS+=("$1")
}

# 记录失败
record_failed() {
    ((FAILED_COUNT++)) || true
    FAILED_TOOLS+=("$1")
}

# 重写 log_skip 以记录跳过
log_skip() {
    echo -e "${YELLOW}[SKIP]${NC} 已安装 $1 (版本: $2)，跳过安装"
    record_skipped "$1"
}

# 重写 log_success 以记录安装 (仅用于工具安装)
log_install_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
    record_installed "$2"
}

#===============================================================================
# 包管理器函数
#===============================================================================

# 包管理器安装函数
install_package() {
    local package=$1
    case $OS in
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

# 更新包管理器
update_package_manager() {
    case $OS in
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

#===============================================================================
# 前端工具安装
#===============================================================================

install_frontend_tools() {
    print_section "前端开发工具"
    
    # nvm (Node Version Manager)
    if [ -d "$HOME/.nvm" ] || command_exists nvm; then
        local nvm_ver=$(bash -c 'source ~/.nvm/nvm.sh 2>/dev/null && nvm --version' 2>/dev/null || echo "installed")
        log_skip "nvm" "$nvm_ver"
    else
        log_info "安装 nvm..."
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
        log_success "nvm 安装完成"
        record_installed "nvm"
    fi
    
    # Node.js (通过 nvm 或直接安装)
    if command_exists node; then
        log_skip "Node.js" "$(node --version)"
    else
        log_info "安装 Node.js LTS..."
        if [ -s "$HOME/.nvm/nvm.sh" ]; then
            source "$HOME/.nvm/nvm.sh"
            nvm install --lts
            nvm use --lts
        else
            case $OS in
                ubuntu|debian)
                    curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
                    sudo apt-get install -y nodejs
                    ;;
                macos)
                    brew install node
                    ;;
            esac
        fi
        log_success "Node.js 安装完成: $(node --version)"
        record_installed "Node.js"
    fi
    
    # npm (随 Node.js 安装)
    if command_exists npm; then
        log_skip "npm" "$(npm --version)"
    fi
    
    # pnpm
    if command_exists pnpm; then
        log_skip "pnpm" "$(pnpm --version)"
    else
        log_info "安装 pnpm..."
        npm install -g pnpm
        log_success "pnpm 安装完成: $(pnpm --version)"
        record_installed "pnpm"
    fi
    
    # yarn
    if command_exists yarn; then
        log_skip "yarn" "$(yarn --version)"
    else
        log_info "安装 yarn..."
        npm install -g yarn
        log_success "yarn 安装完成: $(yarn --version)"
        record_installed "yarn"
    fi
    
    # Bun
    if command_exists bun; then
        log_skip "Bun" "$(bun --version)"
    else
        log_info "安装 Bun..."
        curl -fsSL https://bun.sh/install | bash
        export BUN_INSTALL="$HOME/.bun"
        export PATH="$BUN_INSTALL/bin:$PATH"
        log_success "Bun 安装完成"
        record_installed "Bun"
    fi
    
    # TypeScript
    if npm list -g typescript &>/dev/null; then
        local ts_ver=$(npm list -g typescript 2>/dev/null | grep typescript@ | sed 's/.*typescript@//' | cut -d' ' -f1)
        log_skip "TypeScript" "$ts_ver"
    else
        log_info "安装 TypeScript..."
        npm install -g typescript
        log_success "TypeScript 安装完成"
        record_installed "TypeScript"
    fi
    
    # Vite
    if npm list -g vite &>/dev/null || npm list -g create-vite &>/dev/null; then
        local vite_ver=$(npm list -g vite 2>/dev/null | grep vite@ | sed 's/.*vite@//' | cut -d' ' -f1 || echo "installed")
        log_skip "Vite" "$vite_ver"
    else
        log_info "安装 Vite..."
        npm install -g vite create-vite
        log_success "Vite 安装完成"
        record_installed "Vite"
    fi
    
    # ESLint
    if npm list -g eslint &>/dev/null; then
        local eslint_ver=$(npm list -g eslint 2>/dev/null | grep eslint@ | head -1 | sed 's/.*eslint@//' | cut -d' ' -f1)
        log_skip "ESLint" "$eslint_ver"
    else
        log_info "安装 ESLint..."
        npm install -g eslint
        log_success "ESLint 安装完成"
        record_installed "ESLint"
    fi
    
    # Prettier
    if npm list -g prettier &>/dev/null; then
        local prettier_ver=$(npm list -g prettier 2>/dev/null | grep prettier@ | sed 's/.*prettier@//' | cut -d' ' -f1)
        log_skip "Prettier" "$prettier_ver"
    else
        log_info "安装 Prettier..."
        npm install -g prettier
        log_success "Prettier 安装完成"
    fi
}

#===============================================================================
# 后台工具安装
#===============================================================================

install_backend_tools() {
    print_section "后台开发工具"
    
    # Go
    if command_exists go; then
        log_skip "Go" "$(go version | awk '{print $3}')"
    else
        log_info "安装 Go..."
        case $OS in
            ubuntu|debian)
                sudo snap install go --classic
                ;;
            macos)
                brew install go
                ;;
        esac
        log_success "Go 安装完成"
    fi
    
    # Python
    if command_exists python3; then
        log_skip "Python" "$(python3 --version | awk '{print $2}')"
    else
        log_info "安装 Python..."
        case $OS in
            ubuntu|debian)
                sudo apt-get install -y python3 python3-pip python3-venv
                ;;
            macos)
                brew install python
                ;;
        esac
        log_success "Python 安装完成"
    fi
    
    # pip
    if command_exists pip3; then
        log_skip "pip" "$(pip3 --version | awk '{print $2}')"
    else
        log_info "安装 pip..."
        case $OS in
            ubuntu|debian)
                sudo apt-get install -y python3-pip
                ;;
        esac
        log_success "pip 安装完成"
    fi
    
    # uv (Python 包管理器)
    if command_exists uv; then
        log_skip "uv" "$(uv --version | awk '{print $2}')"
    else
        log_info "安装 uv..."
        curl -LsSf https://astral.sh/uv/install.sh | sh
        log_success "uv 安装完成"
    fi
    
    # Java (OpenJDK)
    if command_exists java; then
        log_skip "Java" "$(java -version 2>&1 | head -1 | awk -F '"' '{print $2}')"
    else
        log_info "安装 Java (OpenJDK)..."
        case $OS in
            ubuntu|debian)
                sudo apt-get install -y openjdk-17-jdk
                ;;
            macos)
                brew install openjdk@17
                ;;
        esac
        log_success "Java 安装完成"
    fi
    
    # Maven
    if command_exists mvn; then
        log_skip "Maven" "$(mvn --version | head -1 | awk '{print $3}')"
    else
        log_info "安装 Maven..."
        case $OS in
            ubuntu|debian)
                sudo apt-get install -y maven
                ;;
            macos)
                brew install maven
                ;;
        esac
        log_success "Maven 安装完成"
    fi
    
    # Gradle
    if command_exists gradle; then
        log_skip "Gradle" "$(gradle --version | grep Gradle | awk '{print $2}')"
    else
        log_info "安装 Gradle..."
        case $OS in
            ubuntu|debian)
                sudo snap install gradle --classic
                ;;
            macos)
                brew install gradle
                ;;
        esac
        log_success "Gradle 安装完成"
    fi
    
    # .NET SDK
    if command_exists dotnet; then
        log_skip ".NET SDK" "$(dotnet --version)"
    else
        log_info "安装 .NET SDK..."
        case $OS in
            ubuntu|debian)
                wget https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb -O /tmp/packages-microsoft-prod.deb
                sudo dpkg -i /tmp/packages-microsoft-prod.deb
                rm /tmp/packages-microsoft-prod.deb
                sudo apt-get update
                sudo apt-get install -y dotnet-sdk-8.0
                ;;
            macos)
                brew install dotnet-sdk
                ;;
        esac
        log_success ".NET SDK 安装完成"
    fi
    
    # gRPC/protobuf
    if command_exists protoc; then
        log_skip "protobuf" "$(protoc --version | awk '{print $2}')"
    else
        log_info "安装 protobuf..."
        case $OS in
            ubuntu|debian)
                sudo apt-get install -y protobuf-compiler
                ;;
            macos)
                brew install protobuf
                ;;
        esac
        log_success "protobuf 安装完成"
    fi
    
    # grpcurl
    if command_exists grpcurl; then
        log_skip "grpcurl" "$(grpcurl --version 2>&1 | head -1)"
    else
        log_info "安装 grpcurl..."
        case $OS in
            ubuntu|debian)
                go install github.com/fullstorydev/grpcurl/cmd/grpcurl@latest 2>/dev/null || {
                    curl -sSL "https://github.com/fullstorydev/grpcurl/releases/download/v1.9.1/grpcurl_1.9.1_linux_x86_64.tar.gz" | sudo tar -xz -C /usr/local/bin grpcurl
                }
                ;;
            macos)
                brew install grpcurl
                ;;
        esac
        log_success "grpcurl 安装完成"
    fi
}

#===============================================================================
# 数据库客户端安装
#===============================================================================

install_database_tools() {
    print_section "数据库客户端"
    
    # PostgreSQL 客户端
    if command_exists psql; then
        log_skip "PostgreSQL 客户端" "$(psql --version | awk '{print $3}')"
    else
        log_info "安装 PostgreSQL 客户端..."
        case $OS in
            ubuntu|debian)
                sudo apt-get install -y postgresql-client
                ;;
            macos)
                brew install libpq
                brew link --force libpq
                ;;
        esac
        log_success "PostgreSQL 客户端安装完成"
    fi
    
    # Redis 客户端
    if command_exists redis-cli; then
        log_skip "Redis 客户端" "$(redis-cli --version | awk '{print $2}')"
    else
        log_info "安装 Redis 客户端..."
        case $OS in
            ubuntu|debian)
                sudo apt-get install -y redis-tools
                ;;
            macos)
                brew install redis
                ;;
        esac
        log_success "Redis 客户端安装完成"
    fi
    
    # SQLite
    if command_exists sqlite3; then
        log_skip "SQLite" "$(sqlite3 --version | awk '{print $1}')"
    else
        log_info "安装 SQLite..."
        case $OS in
            ubuntu|debian)
                sudo apt-get install -y sqlite3
                ;;
            macos)
                brew install sqlite
                ;;
        esac
        log_success "SQLite 安装完成"
    fi
}

#===============================================================================
# 云和 DevOps 工具安装
#===============================================================================

install_cloud_tools() {
    print_section "云和 DevOps 工具"
    
    # Docker
    if command_exists docker; then
        log_skip "Docker" "$(docker --version | awk '{print $3}' | tr -d ',')"
    else
        log_info "安装 Docker..."
        curl -fsSL https://get.docker.com | sh
        log_success "Docker 安装完成"
    fi
    
    # 确保当前用户在 docker 组中
    if command_exists docker; then
        if ! groups $USER | grep -q '\bdocker\b'; then
            log_info "将用户 $USER 添加到 docker 组..."
            sudo usermod -aG docker $USER
            log_success "已添加到 docker 组 (需重新登录或运行 'newgrp docker' 生效)"
        fi
    fi
    
    # Docker Compose
    if command_exists docker-compose || docker compose version &>/dev/null; then
        local dc_ver=$(docker compose version 2>/dev/null | awk '{print $4}' || docker-compose --version | awk '{print $4}')
        log_skip "Docker Compose" "$dc_ver"
    else
        log_info "安装 Docker Compose..."
        sudo apt-get install -y docker-compose-plugin 2>/dev/null || {
            sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
            sudo chmod +x /usr/local/bin/docker-compose
        }
        log_success "Docker Compose 安装完成"
    fi
    
    # kubectl
    if command_exists kubectl; then
        log_skip "kubectl" "$(kubectl version --client -o yaml 2>/dev/null | grep gitVersion | awk '{print $2}' || kubectl version --client --short 2>/dev/null | awk '{print $3}')"
    else
        log_info "安装 kubectl..."
        case $OS in
            ubuntu|debian)
                curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
                sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
                rm kubectl
                ;;
            macos)
                brew install kubectl
                ;;
        esac
        log_success "kubectl 安装完成"
    fi
    
    # Helm
    if command_exists helm; then
        log_skip "Helm" "$(helm version --short | cut -d'+' -f1)"
    else
        log_info "安装 Helm..."
        curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
        log_success "Helm 安装完成"
    fi
    
    # Terraform
    if command_exists terraform; then
        log_skip "Terraform" "$(terraform version | head -1 | awk '{print $2}')"
    else
        log_info "安装 Terraform..."
        case $OS in
            ubuntu|debian)
                wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
                echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
                sudo apt-get update && sudo apt-get install -y terraform
                ;;
            macos)
                brew install terraform
                ;;
        esac
        log_success "Terraform 安装完成"
    fi
    
    # Azure CLI
    if command_exists az; then
        log_skip "Azure CLI" "$(az version -o tsv 2>/dev/null | head -1 || echo 'installed')"
    else
        log_info "安装 Azure CLI..."
        case $OS in
            ubuntu|debian)
                curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
                ;;
            macos)
                brew install azure-cli
                ;;
        esac
        log_success "Azure CLI 安装完成"
    fi
    
    # AWS CLI
    if command_exists aws; then
        log_skip "AWS CLI" "$(aws --version | awk '{print $1}' | cut -d'/' -f2)"
    else
        log_info "安装 AWS CLI..."
        case $OS in
            ubuntu|debian)
                curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip"
                cd /tmp && unzip -q awscliv2.zip && sudo ./aws/install && rm -rf aws awscliv2.zip
                cd - > /dev/null
                ;;
            macos)
                brew install awscli
                ;;
        esac
        log_success "AWS CLI 安装完成"
    fi
    
    # Google Cloud SDK
    if command_exists gcloud; then
        log_skip "gcloud" "$(gcloud version 2>/dev/null | head -1 | awk '{print $4}')"
    else
        log_info "安装 Google Cloud SDK..."
        case $OS in
            ubuntu|debian)
                echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee /etc/apt/sources.list.d/google-cloud-sdk.list
                curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg
                sudo apt-get update && sudo apt-get install -y google-cloud-cli
                ;;
            macos)
                brew install google-cloud-sdk
                ;;
        esac
        log_success "gcloud 安装完成"
    fi
    
    # Ansible
    if command_exists ansible; then
        log_skip "Ansible" "$(ansible --version | head -1 | awk '{print $3}' | tr -d ']')"
    else
        log_info "安装 Ansible..."
        case $OS in
            ubuntu|debian)
                sudo apt-get install -y ansible
                ;;
            macos)
                brew install ansible
                ;;
        esac
        log_success "Ansible 安装完成"
    fi
}

#===============================================================================
# 通用工具安装
#===============================================================================

install_common_tools() {
    print_section "通用开发工具"
    
    # Git
    if command_exists git; then
        log_skip "Git" "$(git --version | awk '{print $3}')"
    else
        log_info "安装 Git..."
        case $OS in
            ubuntu|debian)
                sudo apt-get install -y git
                ;;
            macos)
                brew install git
                ;;
        esac
        log_success "Git 安装完成"
    fi
    
    # GitHub CLI
    if command_exists gh; then
        log_skip "GitHub CLI" "$(gh --version | head -1 | awk '{print $3}')"
    else
        log_info "安装 GitHub CLI..."
        case $OS in
            ubuntu|debian)
                type -p curl >/dev/null || sudo apt install curl -y
                curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
                sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
                echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
                sudo apt update && sudo apt install gh -y
                ;;
            macos)
                brew install gh
                ;;
        esac
        log_success "GitHub CLI 安装完成"
    fi
    
    # jq
    if command_exists jq; then
        log_skip "jq" "$(jq --version)"
    else
        log_info "安装 jq..."
        case $OS in
            ubuntu|debian)
                sudo apt-get install -y jq
                ;;
            macos)
                brew install jq
                ;;
        esac
        log_success "jq 安装完成"
    fi
    
    # yq
    if command_exists yq; then
        log_skip "yq" "$(yq --version | awk '{print $NF}')"
    else
        log_info "安装 yq..."
        case $OS in
            ubuntu|debian)
                sudo wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/local/bin/yq
                sudo chmod +x /usr/local/bin/yq
                ;;
            macos)
                brew install yq
                ;;
        esac
        log_success "yq 安装完成"
    fi
    
    # mkcert
    if command_exists mkcert; then
        log_skip "mkcert" "$(mkcert --version 2>&1 | head -1)"
    else
        log_info "安装 mkcert..."
        case $OS in
            ubuntu|debian)
                sudo apt-get install -y libnss3-tools
                curl -JLO "https://github.com/FiloSottile/mkcert/releases/latest/download/mkcert-v1.4.4-linux-amd64"
                sudo mv mkcert-v1.4.4-linux-amd64 /usr/local/bin/mkcert
                sudo chmod +x /usr/local/bin/mkcert
                ;;
            macos)
                brew install mkcert
                ;;
        esac
        log_success "mkcert 安装完成"
    fi
}

#===============================================================================
# 显示安装摘要
#===============================================================================

show_summary() {
    print_section "安装摘要"
    
    echo ""
    echo -e "${GREEN}前端工具:${NC}"
    command_exists node && echo "  ✓ Node.js: $(node --version)"
    command_exists npm && echo "  ✓ npm: $(npm --version)"
    command_exists pnpm && echo "  ✓ pnpm: $(pnpm --version)"
    command_exists yarn && echo "  ✓ yarn: $(yarn --version)"
    command_exists bun && echo "  ✓ Bun: $(bun --version 2>/dev/null || echo 'installed')"
    npm list -g typescript &>/dev/null && echo "  ✓ TypeScript: installed"
    npm list -g vite &>/dev/null && echo "  ✓ Vite: installed"
    npm list -g eslint &>/dev/null && echo "  ✓ ESLint: installed"
    npm list -g prettier &>/dev/null && echo "  ✓ Prettier: installed"
    [ -d "$HOME/.nvm" ] && echo "  ✓ nvm: installed"
    
    echo ""
    echo -e "${GREEN}后台工具:${NC}"
    command_exists go && echo "  ✓ Go: $(go version | awk '{print $3}')"
    command_exists python3 && echo "  ✓ Python: $(python3 --version | awk '{print $2}')"
    command_exists uv && echo "  ✓ uv: $(uv --version 2>/dev/null | awk '{print $2}' || echo 'installed')"
    command_exists java && echo "  ✓ Java: $(java -version 2>&1 | head -1 | awk -F '"' '{print $2}')"
    command_exists mvn && echo "  ✓ Maven: $(mvn --version 2>/dev/null | head -1 | awk '{print $3}')"
    command_exists gradle && echo "  ✓ Gradle: installed"
    command_exists dotnet && echo "  ✓ .NET: $(dotnet --version)"
    command_exists protoc && echo "  ✓ protobuf: $(protoc --version | awk '{print $2}')"
    
    echo ""
    echo -e "${GREEN}数据库客户端:${NC}"
    command_exists psql && echo "  ✓ PostgreSQL: $(psql --version | awk '{print $3}')"
    command_exists redis-cli && echo "  ✓ Redis: $(redis-cli --version | awk '{print $2}')"
    command_exists sqlite3 && echo "  ✓ SQLite: $(sqlite3 --version | awk '{print $1}')"
    
    echo ""
    echo -e "${GREEN}云和 DevOps:${NC}"
    command_exists docker && echo "  ✓ Docker: $(docker --version | awk '{print $3}' | tr -d ',')"
    (command_exists docker-compose || docker compose version &>/dev/null) && echo "  ✓ Docker Compose: installed"
    command_exists kubectl && echo "  ✓ kubectl: installed"
    command_exists helm && echo "  ✓ Helm: $(helm version --short 2>/dev/null | cut -d'+' -f1)"
    command_exists terraform && echo "  ✓ Terraform: $(terraform version 2>/dev/null | head -1 | awk '{print $2}')"
    command_exists az && echo "  ✓ Azure CLI: installed"
    command_exists aws && echo "  ✓ AWS CLI: $(aws --version | awk '{print $1}' | cut -d'/' -f2)"
    command_exists gcloud && echo "  ✓ gcloud: installed"
    command_exists ansible && echo "  ✓ Ansible: installed"
    
    echo ""
    echo -e "${GREEN}通用工具:${NC}"
    command_exists git && echo "  ✓ Git: $(git --version | awk '{print $3}')"
    command_exists gh && echo "  ✓ GitHub CLI: $(gh --version | head -1 | awk '{print $3}')"
    command_exists jq && echo "  ✓ jq: $(jq --version)"
    command_exists yq && echo "  ✓ yq: $(yq --version 2>/dev/null | awk '{print $NF}')"
    command_exists mkcert && echo "  ✓ mkcert: installed"
    
    echo ""
    print_box_start
    echo -e "${GREEN}安装完成！${NC}"
    echo ""
    echo -e "  📊 ${CYAN}安装摘要${NC}"
    echo -e "  ─────────────────────────────"
    echo -e "  ${GREEN}✓ 新安装:${NC} $INSTALLED_COUNT 个工具"
    echo -e "  ${YELLOW}○ 已跳过:${NC} $SKIPPED_COUNT 个工具 (已存在)"
    if [[ $FAILED_COUNT -gt 0 ]]; then
        echo -e "  ${RED}✗ 失败:${NC}   $FAILED_COUNT 个工具"
    fi
    echo ""
    if [[ ${#INSTALLED_TOOLS[@]} -gt 0 ]]; then
        echo -e "  ${GREEN}新安装的工具:${NC}"
        printf '    %s\n' "${INSTALLED_TOOLS[@]}"
        echo ""
    fi
    if [[ ${#FAILED_TOOLS[@]} -gt 0 ]]; then
        echo -e "  ${RED}安装失败的工具:${NC}"
        printf '    %s\n' "${FAILED_TOOLS[@]}"
        echo ""
    fi
    print_box_end
    echo ""
    echo -e "${YELLOW}提示:${NC}"
    echo "  - 部分工具需要重新打开终端或重新登录才能生效"
    echo "  - 运行 'source ~/.bashrc' 或 'source ~/.zshrc' 刷新环境"
    echo ""
}

#===============================================================================
# 主程序
#===============================================================================

main() {
    print_header "开发工具安装脚本 v1.1"
    
    log_info "检测到系统: $OS"
    echo ""
    
    # 检查 root 权限
    if [[ $EUID -ne 0 ]]; then
        log_warning "部分安装需要 sudo 权限"
    fi
    
    # 更新包管理器
    log_info "更新包管理器..."
    update_package_manager
    
    # 安装基础依赖
    log_info "安装基础依赖..."
    case $OS in
        ubuntu|debian)
            sudo apt-get install -y curl wget unzip gnupg ca-certificates lsb-release apt-transport-https software-properties-common build-essential
            ;;
    esac
    
    # 安装各类工具
    install_frontend_tools
    install_backend_tools
    install_database_tools
    install_cloud_tools
    install_common_tools
    
    # 显示摘要
    show_summary
}

# 运行主程序
main "$@"
