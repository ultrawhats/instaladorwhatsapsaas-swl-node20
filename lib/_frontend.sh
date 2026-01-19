#!/bin/bash
# 
# functions for setting up app frontend

#######################################
# installed node packages
# Arguments:
#   None
#######################################
frontend_node_dependencies() {
  print_banner
  printf "${WHITE} 💻 Instalando dependências do frontend...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  if [ ! -d "/home/deploy/${instancia_add}/frontend" ]; then
    printf "${RED} ❌ Diretório do frontend não encontrado${GRAY_LIGHT}\n"
    return 1
  fi

  sudo su - deploy <<EOF
  cd /home/deploy/${instancia_add}/frontend
  npm install
EOF

  if [ $? -ne 0 ]; then
    printf "${RED} ❌ Erro ao instalar dependências do frontend${GRAY_LIGHT}\n"
    return 1
  fi

  sleep 2
}

#######################################
# compiles frontend code
# Arguments:
#   None
#######################################
frontend_node_build() {
  print_banner
  printf "${WHITE} 💻 Compilando o código do frontend...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  if [ ! -d "/home/deploy/${instancia_add}/frontend" ]; then
    printf "${RED} ❌ Diretório do frontend não encontrado${GRAY_LIGHT}\n"
    return 1
  fi

  sudo su - deploy <<EOF
  cd /home/deploy/${instancia_add}/frontend
  npm run build
EOF

  if [ $? -ne 0 ]; then
    printf "${RED} ❌ Erro ao compilar frontend${GRAY_LIGHT}\n"
    return 1
  fi

  if [ ! -d "/home/deploy/${instancia_add}/frontend/build" ]; then
    printf "${RED} ❌ Diretório de build não encontrado${GRAY_LIGHT}\n"
    return 1
  fi

  sleep 2
}

#######################################
# updates frontend code
# Arguments:
#   None
#######################################
frontend_update() {
  print_banner
  printf "${WHITE} 💻 Atualizando o frontend...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  sudo su - deploy <<EOF
  cd /home/deploy/${empresa_atualizar}
  pm2 stop ${empresa_atualizar}-frontend
  git pull
  cd /home/deploy/${empresa_atualizar}/frontend
  npm install
  rm -rf build
  npm run build
  pm2 start ${empresa_atualizar}-frontend
  pm2 save
EOF

  sleep 2
}


#######################################
# sets frontend environment variables
# Arguments:
#   None
#######################################
frontend_set_env() {
  print_banner
  printf "${WHITE} 💻 Configurando variáveis de ambiente (frontend)...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  # ensure idempotency
  backend_url=$(echo "${backend_url/https:\/\/}")
  backend_url=${backend_url%%/*}
  backend_url=https://$backend_url

sudo su - deploy << EOF
  cat <<[-]EOF > /home/deploy/${instancia_add}/frontend/.env
REACT_APP_BACKEND_URL=${backend_url}
REACT_APP_HOURS_CLOSE_TICKETS_AUTO=24
[-]EOF
EOF

  sleep 2

sudo su - deploy << EOF
  cat <<[-]EOF > /home/deploy/${instancia_add}/frontend/server.js
//simple express server to run frontend production build;
const express = require("express");
const path = require("path");
const app = express();
app.use(express.static(path.join(__dirname, "build")));
app.get("/*", function (req, res) {
	res.sendFile(path.join(__dirname, "build", "index.html"));
});
app.listen(${frontend_port});

[-]EOF
EOF

  sleep 2
}

#######################################
# starts pm2 for frontend
# Arguments:
#   None
#######################################
frontend_start_pm2() {
  print_banner
  printf "${WHITE} 💻 Iniciando pm2 (frontend)...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  if [ ! -f "/home/deploy/${instancia_add}/frontend/server.js" ]; then
    printf "${RED} ❌ Arquivo server.js não encontrado${GRAY_LIGHT}\n"
    return 1
  fi

  # Verificar se já existe um processo com esse nome
  sudo su - deploy <<EOF
  pm2 delete ${instancia_add}-frontend 2>/dev/null || true
  cd /home/deploy/${instancia_add}/frontend
  pm2 start server.js --name ${instancia_add}-frontend
  pm2 save
EOF

  if [ $? -ne 0 ]; then
    printf "${RED} ❌ Erro ao iniciar PM2 para frontend${GRAY_LIGHT}\n"
    return 1
  fi

  sleep 2
  
  # Configurar PM2 para iniciar automaticamente (executar como deploy, não root)
  sudo su - deploy <<EOF
  pm2 startup systemd -u deploy --hp /home/deploy 2>/dev/null || true
EOF
  
  sleep 2
}

#######################################
# sets up nginx for frontend
# Arguments:
#   None
#######################################
frontend_nginx_setup() {
  print_banner
  printf "${WHITE} 💻 Configurando nginx (frontend)...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  frontend_hostname=$(echo "${frontend_url/https:\/\/}")

  # Verificar se o link simbólico já existe
  if [ -L /etc/nginx/sites-enabled/${instancia_add}-frontend ]; then
    sudo rm -f /etc/nginx/sites-enabled/${instancia_add}-frontend
  fi

sudo su - root << EOF
cat > /etc/nginx/sites-available/${instancia_add}-frontend << END
server {
  server_name ${frontend_hostname};

  location / {
    proxy_pass http://127.0.0.1:${frontend_port};
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
ln -s /etc/nginx/sites-available/${instancia_add}-frontend /etc/nginx/sites-enabled
EOF

  if [ $? -ne 0 ]; then
    printf "${RED} ❌ Erro ao configurar nginx para frontend${GRAY_LIGHT}\n"
    exit 1
  fi

  sleep 2
}
