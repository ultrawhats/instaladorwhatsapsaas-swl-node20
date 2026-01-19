#!/bin/bash

get_mysql_root_password() {
  
  print_banner
  printf "${WHITE} 💻 Insira senha para o usuario Deploy e Banco de Dados (Não utilizar caracteres especiais):${GRAY_LIGHT}"
  printf "\n\n"
  while true; do
    read -p "> " mysql_root_password
    if validate_password "$mysql_root_password"; then
      break
    fi
    printf "${WHITE} 💻 Tente novamente:${GRAY_LIGHT}\n"
  done
}

get_link_git() {
  
  print_banner
  printf "${WHITE} 💻 Insira o link do GITHUB do Whaticket que deseja instalar:${GRAY_LIGHT}"
  printf "\n\n"
  while true; do
    read -p "> " link_git
    if validate_git_url "$link_git"; then
      break
    fi
    printf "${WHITE} 💻 Tente novamente:${GRAY_LIGHT}\n"
  done
}

get_git_username() {
  print_banner
  printf "${WHITE} 💻 Insira o usuário do GITHUB:${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " git_username
}

get_git_password() {
  print_banner
  printf "${WHITE} 💻 Insira a senha ou token de acesso do GITHUB:${GRAY_LIGHT}"
  printf "${YELLOW} ⚠️  Para repositórios privados, use um Personal Access Token (PAT)${GRAY_LIGHT}"
  printf "\n\n"
  read -sp "> " git_password
  printf "\n"
}

get_instancia_add() {
  
  print_banner
  printf "${WHITE} 💻 Informe um nome para a Instancia/Empresa que será instalada (Não utilizar espaços ou caracteres especiais, Utilizar Letras minusculas; ):${GRAY_LIGHT}"
  printf "\n\n"
  while true; do
    read -p "> " instancia_add
    if validate_instance_name "$instancia_add"; then
      break
    fi
    printf "${WHITE} 💻 Tente novamente:${GRAY_LIGHT}\n"
  done
}

get_max_whats() {
  
  print_banner
  printf "${WHITE} 💻 Informe a Qtde de Conexões/Whats que a ${instancia_add} poderá cadastrar:${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " max_whats
}

get_max_user() {
  
  print_banner
  printf "${WHITE} 💻 Informe a Qtde de Usuarios/Atendentes que a ${instancia_add} poderá cadastrar:${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " max_user
}

get_frontend_url() {
  
  print_banner
  printf "${WHITE} 💻 Digite o domínio do FRONTEND/PAINEL para a ${instancia_add}:${GRAY_LIGHT}"
  printf "\n\n"
  while true; do
    read -p "> " frontend_url
    if validate_url "$frontend_url"; then
      break
    fi
    printf "${WHITE} 💻 Tente novamente:${GRAY_LIGHT}\n"
  done
}

get_backend_url() {
  
  print_banner
  printf "${WHITE} 💻 Digite o domínio do BACKEND/API para a ${instancia_add}:${GRAY_LIGHT}"
  printf "\n\n"
  while true; do
    read -p "> " backend_url
    if validate_url "$backend_url"; then
      break
    fi
    printf "${WHITE} 💻 Tente novamente:${GRAY_LIGHT}\n"
  done
}

get_frontend_port() {
  
  print_banner
  printf "${WHITE} 💻 Digite a porta do FRONTEND para a ${instancia_add}; Ex: 3000 A 3999 ${GRAY_LIGHT}"
  printf "\n\n"
  while true; do
    read -p "> " frontend_port
    if validate_port "$frontend_port"; then
      break
    fi
    printf "${WHITE} 💻 Tente novamente:${GRAY_LIGHT}\n"
  done
}


get_backend_port() {
  
  print_banner
  printf "${WHITE} 💻 Digite a porta do BACKEND para esta instancia; Ex: 4000 A 4999 ${GRAY_LIGHT}"
  printf "\n\n"
  while true; do
    read -p "> " backend_port
    if validate_port "$backend_port"; then
      break
    fi
    printf "${WHITE} 💻 Tente novamente:${GRAY_LIGHT}\n"
  done
}

get_redis_port() {
  
  print_banner
  printf "${WHITE} 💻 Digite a porta do REDIS/AGENDAMENTO MSG para a ${instancia_add}; Ex: 5000 A 5999 ${GRAY_LIGHT}"
  printf "\n\n"
  while true; do
    read -p "> " redis_port
    if validate_port "$redis_port"; then
      break
    fi
    printf "${WHITE} 💻 Tente novamente:${GRAY_LIGHT}\n"
  done
}

get_empresa_delete() {
  
  print_banner
  printf "${WHITE} 💻 Digite o nome da Instancia/Empresa que será Deletada (Digite o mesmo nome de quando instalou):${GRAY_LIGHT}"
  printf "\n\n"
  while true; do
    read -p "> " empresa_delete
    if validate_instance_exists "$empresa_delete"; then
      break
    fi
    printf "${WHITE} 💻 Tente novamente:${GRAY_LIGHT}\n"
  done
}

get_empresa_atualizar() {
  
  print_banner
  printf "${WHITE} 💻 Digite o nome da Instancia/Empresa que deseja Atualizar (Digite o mesmo nome de quando instalou):${GRAY_LIGHT}"
  printf "\n\n"
  while true; do
    read -p "> " empresa_atualizar
    if validate_instance_exists "$empresa_atualizar"; then
      break
    fi
    printf "${WHITE} 💻 Tente novamente:${GRAY_LIGHT}\n"
  done
}

get_empresa_bloquear() {
  
  print_banner
  printf "${WHITE} 💻 Digite o nome da Instancia/Empresa que deseja Bloquear (Digite o mesmo nome de quando instalou):${GRAY_LIGHT}"
  printf "\n\n"
  while true; do
    read -p "> " empresa_bloquear
    if validate_instance_exists "$empresa_bloquear"; then
      break
    fi
    printf "${WHITE} 💻 Tente novamente:${GRAY_LIGHT}\n"
  done
}

get_empresa_desbloquear() {
  
  print_banner
  printf "${WHITE} 💻 Digite o nome da Instancia/Empresa que deseja Desbloquear (Digite o mesmo nome de quando instalou):${GRAY_LIGHT}"
  printf "\n\n"
  while true; do
    read -p "> " empresa_desbloquear
    if validate_instance_exists "$empresa_desbloquear"; then
      break
    fi
    printf "${WHITE} 💻 Tente novamente:${GRAY_LIGHT}\n"
  done
}

get_empresa_dominio() {
  
  print_banner
  printf "${WHITE} 💻 Digite o nome da Instancia/Empresa que deseja Alterar os Dominios (Atenção para alterar os dominios precisa digitar os 2, mesmo que vá alterar apenas 1):${GRAY_LIGHT}"
  printf "\n\n"
  while true; do
    read -p "> " empresa_dominio
    if validate_instance_exists "$empresa_dominio"; then
      break
    fi
    printf "${WHITE} 💻 Tente novamente:${GRAY_LIGHT}\n"
  done
}

get_alter_frontend_url() {
  
  print_banner
  printf "${WHITE} 💻 Digite o NOVO domínio do FRONTEND/PAINEL para a ${empresa_dominio}:${GRAY_LIGHT}"
  printf "\n\n"
  while true; do
    read -p "> " alter_frontend_url
    if validate_url "$alter_frontend_url"; then
      break
    fi
    printf "${WHITE} 💻 Tente novamente:${GRAY_LIGHT}\n"
  done
}

get_alter_backend_url() {
  
  print_banner
  printf "${WHITE} 💻 Digite o NOVO domínio do BACKEND/API para a ${empresa_dominio}:${GRAY_LIGHT}"
  printf "\n\n"
  while true; do
    read -p "> " alter_backend_url
    if validate_url "$alter_backend_url"; then
      break
    fi
    printf "${WHITE} 💻 Tente novamente:${GRAY_LIGHT}\n"
  done
}

get_alter_frontend_port() {
  
  print_banner
  printf "${WHITE} 💻 Digite a porta do FRONTEND da Instancia/Empresa ${empresa_dominio}; A porta deve ser o mesma informada durante a instalação ${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " alter_frontend_port
}


get_alter_backend_port() {
  
  print_banner
  printf "${WHITE} 💻 Digite a porta do BACKEND da Instancia/Empresa ${empresa_dominio}; A porta deve ser o mesma informada durante a instalação ${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " alter_backend_port
}


get_urls() {
  get_mysql_root_password
  get_link_git
  get_git_username
  get_git_password
  get_instancia_add
  get_max_whats
  get_max_user
  get_frontend_url
  get_backend_url
  get_frontend_port
  get_backend_port
  get_redis_port
  
  # Criar usuário deploy se não existir (após coletar a senha)
  if ! check_deploy_user; then
    printf "${WHITE} 💻 Criando usuário deploy...${GRAY_LIGHT}\n"
    if ! ensure_deploy_user; then
      printf "${RED} ❌ Não foi possível criar o usuário deploy.${GRAY_LIGHT}\n"
      exit 1
    fi
  fi
}

software_update() {
  get_empresa_atualizar
  frontend_update
  backend_update
}

software_delete() {
  get_empresa_delete
  deletar_tudo
}

software_bloquear() {
  get_empresa_bloquear
  configurar_bloqueio
}

software_desbloquear() {
  get_empresa_desbloquear
  configurar_desbloqueio
}

software_dominio() {
  get_empresa_dominio
  get_alter_frontend_url
  get_alter_backend_url
  get_alter_frontend_port
  get_alter_backend_port
  configurar_dominio
}

#######################################
# Installs additional instance (install_instancia flow)
# Arguments:
#   None
#######################################
install_additional_instance() {
  # Validar dependências antes de continuar
  if ! validate_dependencies; then
    printf "${RED} ❌ Dependências faltando. Execute install_primaria primeiro.${GRAY_LIGHT}\n"
    return 1
  fi

  # Coletar informações da instância
  get_urls

  # backend related
  system_git_clone || { printf "${RED} ❌ Erro ao clonar repositório${GRAY_LIGHT}\n"; return 1; }
  backend_set_env || { printf "${RED} ❌ Erro ao configurar variáveis de ambiente do backend${GRAY_LIGHT}\n"; return 1; }
  backend_redis_create || { printf "${RED} ❌ Erro ao criar Redis e PostgreSQL${GRAY_LIGHT}\n"; return 1; }
  backend_node_dependencies || { printf "${RED} ❌ Erro ao instalar dependências do backend${GRAY_LIGHT}\n"; return 1; }
  backend_node_build || { printf "${RED} ❌ Erro ao compilar backend${GRAY_LIGHT}\n"; return 1; }
  backend_db_migrate || { printf "${RED} ❌ Erro ao executar migrações${GRAY_LIGHT}\n"; return 1; }
  backend_db_seed || { printf "${RED} ❌ Erro ao executar seeds${GRAY_LIGHT}\n"; return 1; }
  backend_start_pm2 || { printf "${RED} ❌ Erro ao iniciar PM2 do backend${GRAY_LIGHT}\n"; return 1; }
  backend_nginx_setup || { printf "${RED} ❌ Erro ao configurar nginx do backend${GRAY_LIGHT}\n"; return 1; }

  # frontend related
  frontend_set_env || { printf "${RED} ❌ Erro ao configurar variáveis de ambiente do frontend${GRAY_LIGHT}\n"; return 1; }
  frontend_node_dependencies || { printf "${RED} ❌ Erro ao instalar dependências do frontend${GRAY_LIGHT}\n"; return 1; }
  frontend_node_build || { printf "${RED} ❌ Erro ao compilar frontend${GRAY_LIGHT}\n"; return 1; }
  frontend_start_pm2 || { printf "${RED} ❌ Erro ao iniciar PM2 do frontend${GRAY_LIGHT}\n"; return 1; }
  frontend_nginx_setup || { printf "${RED} ❌ Erro ao configurar nginx do frontend${GRAY_LIGHT}\n"; return 1; }

  # network related
  system_nginx_restart || { printf "${RED} ❌ Erro ao reiniciar nginx${GRAY_LIGHT}\n"; return 1; }
  system_certbot_setup || { printf "${YELLOW} ⚠️  Aviso: Problemas ao configurar certificados SSL${GRAY_LIGHT}\n"; }

  print_banner
  printf "${GREEN} ✅ Instalação concluída com sucesso!${GRAY_LIGHT}\n"
  printf "${WHITE} 💻 Instância ${instancia_add} está pronta para uso.${GRAY_LIGHT}\n"
  printf "\n"
}

inquiry_options() {
  
  print_banner
  printf "${WHITE} 💻 Bem vindo(a) ao Gerenciador SWL, Selecione abaixo a proxima ação!${GRAY_LIGHT}"
  printf "\n\n"
  printf "   [0] Instalar whaticket (Primeira instalação)\n"
  printf "   [1] Instalar instância adicional\n"
  printf "   [2] Atualizar whaticket\n"
  printf "   [3] Deletar Whaticket\n"
  printf "   [4] Bloquear Whaticket\n"
  printf "   [5] Desbloquear Whaticket\n"
  printf "   [6] Alter. dominio Whaticket\n"
  printf "\n"
  read -p "> " option

  case "${option}" in
    0) get_urls ;;

    1) 
      install_additional_instance
      exit
      ;;

    2) 
      software_update 
      exit
      ;;

    3) 
      software_delete 
      exit
      ;;
    4) 
      software_bloquear 
      exit
      ;;
    5) 
      software_desbloquear 
      exit
      ;;
    6) 
      software_dominio 
      exit
      ;;        

    *) exit ;;
  esac
}


