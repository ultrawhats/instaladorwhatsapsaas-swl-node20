#!/bin/bash
#
# functions for setting up app backend
#######################################
# creates REDIS db using docker
# Arguments:
#   None
#######################################
backend_redis_create() {
  print_banner
  printf "${WHITE} 💻 Criando Redis & Banco Postgres...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  # Verificar se o container Redis já existe
  if docker ps -a --format '{{.Names}}' | grep -q "^redis-${instancia_add}$"; then
    printf "${YELLOW} ⚠️  Container Redis já existe. Removendo...${GRAY_LIGHT}\n"
    docker rm -f redis-${instancia_add} 2>/dev/null || true
  fi

  sudo usermod -aG docker deploy 2>/dev/null || true
  
  # Criar container Redis
  if ! docker run --name redis-${instancia_add} -p ${redis_port}:6379 --restart always --detach redis redis-server --requirepass ${mysql_root_password}; then
    printf "${RED} ❌ Erro ao criar container Redis${GRAY_LIGHT}\n"
    exit 1
  fi

  sleep 2

  # Verificar se o banco de dados já existe
  if sudo -u postgres psql -lqt | cut -d \| -f 1 | grep -qw ${instancia_add}; then
    printf "${YELLOW} ⚠️  Banco de dados já existe. Removendo...${GRAY_LIGHT}\n"
    sudo -u postgres dropdb ${instancia_add} 2>/dev/null || true
  fi

  # Verificar se o usuário já existe
  if sudo -u postgres psql -tAc "SELECT 1 FROM pg_roles WHERE rolname='${instancia_add}'" | grep -q 1; then
    printf "${YELLOW} ⚠️  Usuário já existe. Removendo...${GRAY_LIGHT}\n"
    sudo -u postgres dropuser ${instancia_add} 2>/dev/null || true
  fi

  # Criar banco de dados e usuário
  sudo -u postgres createdb ${instancia_add} || {
    printf "${RED} ❌ Erro ao criar banco de dados${GRAY_LIGHT}\n"
    exit 1
  }

  sudo -u postgres psql -c "CREATE USER ${instancia_add} WITH SUPERUSER INHERIT CREATEDB CREATEROLE PASSWORD '${mysql_root_password}';" || {
    printf "${RED} ❌ Erro ao criar usuário do banco de dados${GRAY_LIGHT}\n"
    exit 1
  }

  printf "${GREEN} ✅ Redis e PostgreSQL configurados com sucesso${GRAY_LIGHT}\n"
  sleep 2
}

#######################################
# sets environment variable for backend.
# Arguments:
#   None
#######################################
backend_set_env() {
  print_banner
  printf "${WHITE} 💻 Configurando variáveis de ambiente (backend)...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  # ensure idempotency
  backend_url=$(echo "${backend_url/https:\/\/}")
  backend_url=${backend_url%%/*}
  backend_url=https://$backend_url

  # ensure idempotency
  frontend_url=$(echo "${frontend_url/https:\/\/}")
  frontend_url=${frontend_url%%/*}
  frontend_url=https://$frontend_url

sudo su - deploy << EOF
  cat <<[-]EOF > /home/deploy/${instancia_add}/backend/.env
NODE_ENV=
BACKEND_URL=${backend_url}
FRONTEND_URL=${frontend_url}
PROXY_PORT=443
PORT=${backend_port}

DB_DIALECT=postgres
DB_HOST=localhost
DB_PORT=5432
DB_USER=${instancia_add}
DB_PASS=${mysql_root_password}
DB_NAME=${instancia_add}

JWT_SECRET=${jwt_secret}
JWT_REFRESH_SECRET=${jwt_refresh_secret}

REDIS_URI=redis://:${mysql_root_password}@127.0.0.1:${redis_port}
REDIS_OPT_LIMITER_MAX=1
REDIS_OPT_LIMITER_DURATION=3000

USER_LIMIT=${max_user}
CONNECTIONS_LIMIT=${max_whats}
CLOSED_SEND_BY_ME=true

MAIL_HOST="smtp.hostinger.com"
MAIL_USER="contato@seusite.com"
MAIL_PASS="senha"
MAIL_FROM="Recuperar Senha <contato@seusite.com>"
MAIL_PORT="465"

[-]EOF
EOF

  sleep 2
}

#######################################
# installs node.js dependencies
# Arguments:
#   None
#######################################
backend_node_dependencies() {
  print_banner
  printf "${WHITE} 💻 Instalando dependências do backend...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  if [ ! -d "/home/deploy/${instancia_add}/backend" ]; then
    printf "${RED} ❌ Diretório do backend não encontrado${GRAY_LIGHT}\n"
    return 1
  fi

  sudo su - deploy <<EOF
  cd /home/deploy/${instancia_add}/backend
  npm install
EOF

  if [ $? -ne 0 ]; then
    printf "${RED} ❌ Erro ao instalar dependências do backend${GRAY_LIGHT}\n"
    return 1
  fi

  sleep 2
}

#######################################
# compiles backend code
# Arguments:
#   None
#######################################
backend_node_build() {
  print_banner
  printf "${WHITE} 💻 Compilando o código do backend...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  if [ ! -d "/home/deploy/${instancia_add}/backend" ]; then
    printf "${RED} ❌ Diretório do backend não encontrado${GRAY_LIGHT}\n"
    return 1
  fi

  sudo su - deploy <<EOF
  cd /home/deploy/${instancia_add}/backend
  npm run build
EOF

  if [ $? -ne 0 ]; then
    printf "${RED} ❌ Erro ao compilar backend${GRAY_LIGHT}\n"
    return 1
  fi

  if [ ! -f "/home/deploy/${instancia_add}/backend/dist/server.js" ]; then
    printf "${RED} ❌ Arquivo compilado não encontrado${GRAY_LIGHT}\n"
    return 1
  fi

  sleep 2
}

#######################################
# updates frontend code
# Arguments:
#   None
#######################################
backend_update() {
  print_banner
  printf "${WHITE} 💻 Atualizando o backend...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  sudo su - deploy <<EOF
  cd /home/deploy/${empresa_atualizar}
  pm2 stop ${empresa_atualizar}-backend
  git pull
  cd /home/deploy/${empresa_atualizar}/backend
  npm install
  npm update -f
  npm install @types/fs-extra
  rm -rf dist 
  npm run build
  npx sequelize db:migrate
  npx sequelize db:migrate
  npx sequelize db:seed
  pm2 start ${empresa_atualizar}-backend
  pm2 save 
EOF

  sleep 2
}

#######################################
# runs db migrate
# Arguments:
#   None
#######################################
backend_db_migrate() {
  print_banner
  printf "${WHITE} 💻 Executando db:migrate...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  if [ ! -d "/home/deploy/${instancia_add}/backend" ]; then
    printf "${RED} ❌ Diretório do backend não encontrado${GRAY_LIGHT}\n"
    return 1
  fi

  sudo su - deploy <<EOF
  cd /home/deploy/${instancia_add}/backend
  npx sequelize db:migrate
EOF

  if [ $? -ne 0 ]; then
    printf "${RED} ❌ Erro ao executar migrações${GRAY_LIGHT}\n"
    return 1
  fi

  sleep 2
}

#######################################
# runs db seed
# Arguments:
#   None
#######################################
backend_db_seed() {
  print_banner
  printf "${WHITE} 💻 Executando db:seed...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  if [ ! -d "/home/deploy/${instancia_add}/backend" ]; then
    printf "${RED} ❌ Diretório do backend não encontrado${GRAY_LIGHT}\n"
    return 1
  fi

  sudo su - deploy <<EOF
  cd /home/deploy/${instancia_add}/backend
  npx sequelize db:seed:all
EOF

  if [ $? -ne 0 ]; then
    printf "${YELLOW} ⚠️  Aviso: Erro ao executar seeds (pode ser normal se já foram executados)${GRAY_LIGHT}\n"
  fi

  sleep 2
}

#######################################
# starts backend using pm2 in 
# production mode.
# Arguments:
#   None
#######################################
backend_start_pm2() {
  print_banner
  printf "${WHITE} 💻 Iniciando pm2 (backend)...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  if [ ! -f "/home/deploy/${instancia_add}/backend/dist/server.js" ]; then
    printf "${RED} ❌ Arquivo compilado não encontrado${GRAY_LIGHT}\n"
    return 1
  fi

  # Verificar se já existe um processo com esse nome
  sudo su - deploy <<EOF
  pm2 delete ${instancia_add}-backend 2>/dev/null || true
  cd /home/deploy/${instancia_add}/backend
  pm2 start dist/server.js --name ${instancia_add}-backend
EOF

  if [ $? -ne 0 ]; then
    printf "${RED} ❌ Erro ao iniciar PM2 do backend${GRAY_LIGHT}\n"
    return 1
  fi

  sleep 2
}

#######################################
# updates frontend code
# Arguments:
#   None
#######################################
backend_nginx_setup() {
  print_banner
  printf "${WHITE} 💻 Configurando nginx (backend)...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  backend_hostname=$(echo "${backend_url/https:\/\/}")

  # Verificar se o link simbólico já existe
  if [ -L /etc/nginx/sites-enabled/${instancia_add}-backend ]; then
    sudo rm -f /etc/nginx/sites-enabled/${instancia_add}-backend
  fi

sudo su - root << EOF
cat > /etc/nginx/sites-available/${instancia_add}-backend << END
server {
  server_name ${backend_hostname};
  location / {
    proxy_pass http://127.0.0.1:${backend_port};
    proxy_http_version 1.1;
    proxy_set_header Upgrade \\\$http_upgrade;
    proxy_set_header Connection 'upgrade';
    proxy_set_header Host \\\$host;
    proxy_set_header X-Real-IP \\\$remote_addr;
    proxy_set_header X-Forwarded-Proto \\\$scheme;
    proxy_set_header X-Forwarded-For \\\$proxy_add_x_forwarded_for;
    proxy_cache_bypass \\\$http_upgrade;
  }
}
END
ln -s /etc/nginx/sites-available/${instancia_add}-backend /etc/nginx/sites-enabled
EOF

  if [ $? -ne 0 ]; then
    printf "${RED} ❌ Erro ao configurar nginx para backend${GRAY_LIGHT}\n"
    exit 1
  fi

  sleep 2
}
