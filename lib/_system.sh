#!/bin/bash
# 
# system management

#######################################
# creates user
# Arguments:
#   None
#######################################
system_create_user() {
  print_banner
  printf "${WHITE} 💻 Verificando usuário deploy...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  # Verificar se o usuário já existe
  if id "deploy" &>/dev/null; then
    printf "${GREEN} ✅ Usuário deploy já existe${GRAY_LIGHT}\n"
    # Garantir que está no grupo sudo
    sudo usermod -aG sudo deploy 2>/dev/null || true
    sleep 2
    return 0
  fi

  printf "${WHITE} 💻 Criando usuário deploy...${GRAY_LIGHT}\n"

  # Validar se a senha foi definida
  if [ -z "${mysql_root_password}" ]; then
    printf "${RED} ❌ Senha não foi definida. Execute o script novamente.${GRAY_LIGHT}\n"
    return 1
  fi

  # Criar usuário sem senha primeiro (mais compatível)
  sudo useradd -m -s /bin/bash deploy

  if [ $? -ne 0 ]; then
    printf "${RED} ❌ Erro ao criar usuário deploy${GRAY_LIGHT}\n"
    return 1
  fi

  # Definir senha usando chpasswd (método mais confiável e compatível)
  echo "deploy:${mysql_root_password}" | sudo chpasswd

  if [ $? -ne 0 ]; then
    printf "${YELLOW} ⚠️  Aviso: Erro ao definir senha, mas usuário foi criado${GRAY_LIGHT}\n"
    # Não falhar aqui, o usuário foi criado
  fi

  # Adicionar ao grupo sudo
  sudo usermod -aG sudo deploy

  if [ $? -ne 0 ]; then
    printf "${RED} ❌ Erro ao adicionar usuário ao grupo sudo${GRAY_LIGHT}\n"
    return 1
  fi

  # Criar diretório home se não existir
  if [ ! -d "/home/deploy" ]; then
    sudo mkdir -p /home/deploy
    sudo chown deploy:deploy /home/deploy
  fi

  printf "${GREEN} ✅ Usuário deploy criado com sucesso${GRAY_LIGHT}\n"
  sleep 2
}

#######################################
# clones repostories using git
# Arguments:
#   None
#######################################
system_git_clone() {
  print_banner
  printf "${WHITE} 💻 Fazendo download do código Whaticket...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  # Verificar se o usuário deploy existe
  if ! check_deploy_user; then
    printf "${RED} ❌ Usuário deploy não existe!${GRAY_LIGHT}\n"
    return 1
  fi

  # Verificar se o diretório já existe
  if [ -d "/home/deploy/${instancia_add}" ]; then
    printf "${YELLOW} ⚠️  Diretório já existe. Removendo...${GRAY_LIGHT}\n"
    sudo rm -rf /home/deploy/${instancia_add}
  fi

  # Verificar se é URL HTTPS e precisa de autenticação
  if [[ "${link_git}" =~ ^https:// ]]; then
    # Se usuário e senha foram fornecidos, usar na URL
    if [ -n "${git_username}" ] && [ -n "${git_password}" ]; then
      # Extrair a parte da URL após https://
      GIT_URL_PART=$(echo "${link_git}" | sed 's|https://||')
      # Montar URL com credenciais
      GIT_URL_WITH_AUTH="https://${git_username}:${git_password}@${GIT_URL_PART}"
      
      sudo su - deploy <<EOF
      git clone ${GIT_URL_WITH_AUTH} /home/deploy/${instancia_add}/
EOF
    else
      # Tentar clone normal (pode pedir credenciais interativamente)
      sudo su - deploy <<EOF
      git clone ${link_git} /home/deploy/${instancia_add}/
EOF
    fi
  elif [[ "${link_git}" =~ ^git@ ]]; then
    # SSH - não precisa de credenciais na URL
    sudo su - deploy <<EOF
      git clone ${link_git} /home/deploy/${instancia_add}/
EOF
  else
    # URL não reconhecida, tentar clone normal
    sudo su - deploy <<EOF
      git clone ${link_git} /home/deploy/${instancia_add}/
EOF
  fi

  if [ $? -ne 0 ]; then
    printf "${RED} ❌ Erro ao clonar repositório Git${GRAY_LIGHT}\n"
    printf "${YELLOW} 💻 Verifique se o repositório existe e se as credenciais estão corretas${GRAY_LIGHT}\n"
    return 1
  fi

  if [ ! -d "/home/deploy/${instancia_add}" ]; then
    printf "${RED} ❌ Diretório não foi criado após clone${GRAY_LIGHT}\n"
    return 1
  fi

  # Limpar credenciais da memória (segurança)
  unset git_password
  unset GIT_URL_WITH_AUTH

  printf "${GREEN} ✅ Repositório clonado com sucesso${GRAY_LIGHT}\n"
  sleep 2
}

#######################################
# updates system
# Arguments:
#   None
#######################################
system_update() {
  print_banner
  printf "${WHITE} 💻 Vamos atualizar o sistema Whaticket...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  sudo su - root <<EOF
  apt -y update
  sudo apt-get install -y libxshmfence-dev libgbm-dev wget unzip fontconfig locales gconf-service libasound2 libatk1.0-0 libc6 libcairo2 libcups2 libdbus-1-3 libexpat1 libfontconfig1 libgcc1 libgconf-2-4 libgdk-pixbuf2.0-0 libglib2.0-0 libgtk-3-0 libnspr4 libpango-1.0-0 libpangocairo-1.0-0 libstdc++6 libx11-6 libx11-xcb1 libxcb1 libxcomposite1 libxcursor1 libxdamage1 libxext6 libxfixes3 libxi6 libxrandr2 libxrender1 libxss1 libxtst6 ca-certificates fonts-liberation libappindicator1 libnss3 lsb-release xdg-utils
EOF

  sleep 2
}



#######################################
# delete system
# Arguments:
#   None
#######################################
deletar_tudo() {
  print_banner
  printf "${WHITE} 💻 Vamos deletar o Whaticket...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  # Remover container Redis
  if docker ps -a --format '{{.Names}}' | grep -q "^redis-${empresa_delete}$"; then
    printf "${WHITE} 💻 Removendo container Redis...${GRAY_LIGHT}\n"
    docker container rm redis-${empresa_delete} --force 2>/dev/null || true
  fi

  # Remover configurações do nginx
  printf "${WHITE} 💻 Removendo configurações do nginx...${GRAY_LIGHT}\n"
  sudo rm -f /etc/nginx/sites-enabled/${empresa_delete}-frontend
  sudo rm -f /etc/nginx/sites-enabled/${empresa_delete}-backend
  sudo rm -f /etc/nginx/sites-available/${empresa_delete}-frontend
  sudo rm -f /etc/nginx/sites-available/${empresa_delete}-backend

  # Remover certificados SSL do certbot (se existirem)
  if [ -d /etc/letsencrypt/live ]; then
    printf "${WHITE} 💻 Verificando certificados SSL...${GRAY_LIGHT}\n"
    # Tentar remover certificados relacionados (certbot delete não é interativo, então usamos rm)
    sudo certbot delete --cert-name $(sudo certbot certificates 2>/dev/null | grep -A 2 "${empresa_delete}" | grep "Certificate Name" | awk '{print $3}') --non-interactive 2>/dev/null || true
  fi

  sleep 2

  # Remover banco de dados e usuário PostgreSQL
  if sudo -u postgres psql -lqt | cut -d \| -f 1 | grep -qw ${empresa_delete}; then
    printf "${WHITE} 💻 Removendo banco de dados PostgreSQL...${GRAY_LIGHT}\n"
    sudo -u postgres dropdb ${empresa_delete} 2>/dev/null || true
  fi

  if sudo -u postgres psql -tAc "SELECT 1 FROM pg_roles WHERE rolname='${empresa_delete}'" | grep -q 1; then
    printf "${WHITE} 💻 Removendo usuário PostgreSQL...${GRAY_LIGHT}\n"
    sudo -u postgres dropuser ${empresa_delete} 2>/dev/null || true
  fi

  sleep 2

  # Remover diretório e processos PM2
  sudo su - deploy <<EOF
  if [ -d /home/deploy/${empresa_delete} ]; then
    rm -rf /home/deploy/${empresa_delete}
  fi
  pm2 delete ${empresa_delete}-frontend ${empresa_delete}-backend 2>/dev/null || true
  pm2 save
EOF

  # Reiniciar nginx
  sudo service nginx restart 2>/dev/null || true

  sleep 2

  print_banner
  printf "${GREEN} ✅ Remoção da Instancia/Empresa ${empresa_delete} realizado com sucesso!${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2
}

#######################################
# bloquear system
# Arguments:
#   None
#######################################
configurar_bloqueio() {
  print_banner
  printf "${WHITE} 💻 Vamos bloquear o Whaticket...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

sudo su - deploy <<EOF
 pm2 stop ${empresa_bloquear}-backend
 pm2 save
EOF

  sleep 2

  print_banner
  printf "${WHITE} 💻 Bloqueio da Instancia/Empresa ${empresa_bloquear} realizado com sucesso ...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2
}


#######################################
# desbloquear system
# Arguments:
#   None
#######################################
configurar_desbloqueio() {
  print_banner
  printf "${WHITE} 💻 Vamos Desbloquear o Whaticket...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

sudo su - deploy <<EOF
 pm2 start ${empresa_bloquear}-backend
 pm2 save
EOF

  sleep 2

  print_banner
  printf "${WHITE} 💻 Desbloqueio da Instancia/Empresa ${empresa_desbloquear} realizado com sucesso ...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2
}

#######################################
# alter dominio system
# Arguments:
#   None
#######################################
configurar_dominio() {
  print_banner
  printf "${WHITE} 💻 Vamos Alterar os Dominios do Whaticket...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  # Validar se a instância existe
  if [ ! -d "/home/deploy/${empresa_dominio}" ]; then
    printf "${RED} ❌ Instância ${empresa_dominio} não encontrada${GRAY_LIGHT}\n"
    exit 1
  fi

  # Normalizar URLs
  alter_backend_url=$(echo "${alter_backend_url/https:\/\/}")
  alter_backend_url=${alter_backend_url%%/*}
  alter_backend_url=https://${alter_backend_url}
  
  alter_frontend_url=$(echo "${alter_frontend_url/https:\/\/}")
  alter_frontend_url=${alter_frontend_url%%/*}
  alter_frontend_url=https://${alter_frontend_url}

  # Remover configurações antigas do nginx
  sudo rm -f /etc/nginx/sites-enabled/${empresa_dominio}-frontend
  sudo rm -f /etc/nginx/sites-enabled/${empresa_dominio}-backend
  sudo rm -f /etc/nginx/sites-available/${empresa_dominio}-frontend
  sudo rm -f /etc/nginx/sites-available/${empresa_dominio}-backend

  sleep 2

  # Atualizar arquivos .env
  sudo su - deploy <<EOF
  if [ -f /home/deploy/${empresa_dominio}/frontend/.env ]; then
    sed -i "s|REACT_APP_BACKEND_URL=.*|REACT_APP_BACKEND_URL=${alter_backend_url}|" /home/deploy/${empresa_dominio}/frontend/.env
  fi
  
  if [ -f /home/deploy/${empresa_dominio}/backend/.env ]; then
    sed -i "s|BACKEND_URL=.*|BACKEND_URL=${alter_backend_url}|" /home/deploy/${empresa_dominio}/backend/.env
    sed -i "s|FRONTEND_URL=.*|FRONTEND_URL=${alter_frontend_url}|" /home/deploy/${empresa_dominio}/backend/.env
  fi
EOF

  if [ $? -ne 0 ]; then
    printf "${RED} ❌ Erro ao atualizar arquivos .env${GRAY_LIGHT}\n"
    exit 1
  fi

  sleep 2
   
  backend_hostname=$(echo "${alter_backend_url/https:\/\/}")

  # Criar configuração do nginx para backend
  sudo tee /etc/nginx/sites-available/${empresa_dominio}-backend > /dev/null << END
server {
  server_name ${backend_hostname};
  location / {
    proxy_pass http://127.0.0.1:${alter_backend_port};
    proxy_http_version 1.1;
    proxy_set_header Upgrade \$http_upgrade;
    proxy_set_header Connection 'upgrade';
    proxy_set_header Host \$host;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-Proto \$scheme;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_cache_bypass \$http_upgrade;
  }
}
END

  sudo ln -sf /etc/nginx/sites-available/${empresa_dominio}-backend /etc/nginx/sites-enabled/

  sleep 2

  frontend_hostname=$(echo "${alter_frontend_url/https:\/\/}")

  # Criar configuração do nginx para frontend
  sudo tee /etc/nginx/sites-available/${empresa_dominio}-frontend > /dev/null << END
server {
  server_name ${frontend_hostname};
  location / {
    proxy_pass http://127.0.0.1:${alter_frontend_port};
    proxy_http_version 1.1;
    proxy_set_header Upgrade \$http_upgrade;
    proxy_set_header Connection 'upgrade';
    proxy_set_header Host \$host;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-Proto \$scheme;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_cache_bypass \$http_upgrade;
  }
}
END

  sudo ln -sf /etc/nginx/sites-available/${empresa_dominio}-frontend /etc/nginx/sites-enabled/

  sleep 2

  # Testar configuração do nginx
  sudo nginx -t
  if [ $? -ne 0 ]; then
    printf "${RED} ❌ Erro na configuração do nginx${GRAY_LIGHT}\n"
    exit 1
  fi

  sudo service nginx restart

  if [ $? -ne 0 ]; then
    printf "${RED} ❌ Erro ao reiniciar nginx${GRAY_LIGHT}\n"
    exit 1
  fi

  sleep 2

  # Obter certificados SSL
  backend_domain=$(echo "${alter_backend_url/https:\/\/}")
  frontend_domain=$(echo "${alter_frontend_url/https:\/\/}")

  printf "${WHITE} 💻 Obtendo certificados SSL...${GRAY_LIGHT}\n"
  sudo certbot -m ${deploy_email} \
          --nginx \
          --agree-tos \
          --non-interactive \
          --domains ${backend_domain},${frontend_domain} 2>&1

  if [ $? -ne 0 ]; then
    printf "${YELLOW} ⚠️  Aviso: Certbot pode ter encontrado problemas. Verifique manualmente.${GRAY_LIGHT}\n"
  fi

  sleep 2

  print_banner
  printf "${GREEN} ✅ Alteração de dominio da Instancia/Empresa ${empresa_dominio} realizado com sucesso!${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2
}

#######################################
# installs node
# Arguments:
#   None
#######################################
system_node_install() {
  print_banner
  printf "${WHITE} 💻 Instalando nodejs...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  sudo su - root <<EOF
  curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
  apt-get install -y nodejs
  sleep 2
  npm install -g npm@latest
  sleep 2
  sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
  wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
  sudo apt-get update -y && sudo apt-get -y install postgresql
  sleep 2
  sudo timedatectl set-timezone America/Sao_Paulo
  
EOF

  sleep 2
}
#######################################
# installs docker
# Arguments:
#   None
#######################################
system_docker_install() {
  print_banner
  printf "${WHITE} 💻 Instalando docker...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  # Detectar distribuição e versão
  if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
    VERSION=$VERSION_ID
  else
    printf "${RED} ❌ Não foi possível detectar a distribuição${GRAY_LIGHT}\n"
    exit 1
  fi

  sudo su - root <<EOF
  apt install -y apt-transport-https \
                 ca-certificates curl \
                 software-properties-common

  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
  
  # Usar a versão detectada ao invés de fixar "bionic"
  add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu \$(lsb_release -cs) stable"

  apt update -y
  apt install -y docker-ce docker-ce-cli containerd.io

  # Iniciar e habilitar docker
  systemctl start docker
  systemctl enable docker
EOF

  if [ $? -ne 0 ]; then
    printf "${RED} ❌ Erro ao instalar Docker${GRAY_LIGHT}\n"
    exit 1
  fi

  sleep 2
}

#######################################
# Ask for file location containing
# multiple URL for streaming.
# Globals:
#   WHITE
#   GRAY_LIGHT
#   BATCH_DIR
#   PROJECT_ROOT
# Arguments:
#   None
#######################################
system_puppeteer_dependencies() {
  print_banner
  printf "${WHITE} 💻 Instalando puppeteer dependencies...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  sudo su - root <<EOF
  apt-get install -y libxshmfence-dev \
                      libgbm-dev \
                      wget \
                      unzip \
                      fontconfig \
                      locales \
                      gconf-service \
                      libasound2 \
                      libatk1.0-0 \
                      libc6 \
                      libcairo2 \
                      libcups2 \
                      libdbus-1-3 \
                      libexpat1 \
                      libfontconfig1 \
                      libgcc1 \
                      libgconf-2-4 \
                      libgdk-pixbuf2.0-0 \
                      libglib2.0-0 \
                      libgtk-3-0 \
                      libnspr4 \
                      libpango-1.0-0 \
                      libpangocairo-1.0-0 \
                      libstdc++6 \
                      libx11-6 \
                      libx11-xcb1 \
                      libxcb1 \
                      libxcomposite1 \
                      libxcursor1 \
                      libxdamage1 \
                      libxext6 \
                      libxfixes3 \
                      libxi6 \
                      libxrandr2 \
                      libxrender1 \
                      libxss1 \
                      libxtst6 \
                      ca-certificates \
                      fonts-liberation \
                      libappindicator1 \
                      libnss3 \
                      lsb-release \
                      xdg-utils
EOF

  sleep 2
}

#######################################
# installs pm2
# Arguments:
#   None
#######################################
system_pm2_install() {
  print_banner
  printf "${WHITE} 💻 Instalando pm2...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  sudo su - root <<EOF
  npm install -g pm2

EOF

  sleep 2
}

#######################################
# installs snapd
# Arguments:
#   None
#######################################
system_snapd_install() {
  print_banner
  printf "${WHITE} 💻 Instalando snapd...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  sudo su - root <<EOF
  apt install -y snapd
  snap install core
  snap refresh core
EOF

  sleep 2
}

#######################################
# installs certbot
# Arguments:
#   None
#######################################
system_certbot_install() {
  print_banner
  printf "${WHITE} 💻 Instalando certbot...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  sudo su - root <<EOF
  apt-get remove certbot
  snap install --classic certbot
  ln -s /snap/bin/certbot /usr/bin/certbot
EOF

  sleep 2
}

#######################################
# installs nginx
# Arguments:
#   None
#######################################
system_nginx_install() {
  print_banner
  printf "${WHITE} 💻 Instalando nginx...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  sudo su - root <<EOF
  apt install -y nginx
  rm /etc/nginx/sites-enabled/default
EOF

  sleep 2
}

#######################################
# restarts nginx
# Arguments:
#   None
#######################################
system_nginx_restart() {
  print_banner
  printf "${WHITE} 💻 reiniciando nginx...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  # Testar configuração antes de reiniciar
  sudo nginx -t
  if [ $? -ne 0 ]; then
    printf "${RED} ❌ Erro na configuração do nginx. Verifique os logs.${GRAY_LIGHT}\n"
    return 1
  fi

  sudo service nginx restart

  if [ $? -ne 0 ]; then
    printf "${RED} ❌ Erro ao reiniciar nginx${GRAY_LIGHT}\n"
    return 1
  fi

  printf "${GREEN} ✅ Nginx reiniciado com sucesso${GRAY_LIGHT}\n"
  sleep 2
}

#######################################
# setup for nginx.conf
# Arguments:
#   None
#######################################
system_nginx_conf() {
  print_banner
  printf "${WHITE} 💻 configurando nginx...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

sudo su - root << EOF

cat > /etc/nginx/conf.d/deploy.conf << 'END'
client_max_body_size 100M;
END

EOF

  sleep 2
}

#######################################
# installs nginx
# Arguments:
#   None
#######################################
system_certbot_setup() {
  print_banner
  printf "${WHITE} 💻 Configurando certbot...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  # Validar se as URLs foram definidas
  if [ -z "${backend_url}" ] || [ -z "${frontend_url}" ]; then
    printf "${RED} ❌ URLs do backend e frontend não foram definidas${GRAY_LIGHT}\n"
    exit 1
  fi

  backend_domain=$(echo "${backend_url/https:\/\/}")
  backend_domain=${backend_domain%%/*}
  frontend_domain=$(echo "${frontend_url/https:\/\/}")
  frontend_domain=${frontend_domain%%/*}

  # Validar formato dos domínios
  if [ -z "${backend_domain}" ] || [ -z "${frontend_domain}" ]; then
    printf "${RED} ❌ Domínios inválidos${GRAY_LIGHT}\n"
    exit 1
  fi

  printf "${WHITE} 💻 Obtendo certificados SSL para ${backend_domain} e ${frontend_domain}...${GRAY_LIGHT}\n"

  sudo certbot -m ${deploy_email} \
          --nginx \
          --agree-tos \
          --non-interactive \
          --domains ${backend_domain},${frontend_domain} 2>&1

  if [ $? -ne 0 ]; then
    printf "${YELLOW} ⚠️  Aviso: Certbot pode ter encontrado problemas. Verifique manualmente.${GRAY_LIGHT}\n"
  else
    printf "${GREEN} ✅ Certificados SSL configurados com sucesso${GRAY_LIGHT}\n"
  fi

  sleep 2
}
