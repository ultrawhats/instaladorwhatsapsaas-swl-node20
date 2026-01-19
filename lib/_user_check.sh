#!/bin/bash
#
# User validation functions

#######################################
# Checks if deploy user exists
# Arguments:
#   None
# Returns:
#   0 if exists, 1 otherwise
#######################################
check_deploy_user() {
  if id "deploy" &>/dev/null; then
    return 0
  else
    return 1
  fi
}

#######################################
# Validates deploy user exists or creates it
# Arguments:
#   None
# Returns:
#   0 if exists or created, 1 otherwise
#######################################
ensure_deploy_user() {
  if check_deploy_user; then
    printf "${GREEN} ✅ Usuário deploy existe${GRAY_LIGHT}\n"
    return 0
  fi

  printf "${YELLOW} ⚠️  Usuário deploy não existe. Tentando criar...${GRAY_LIGHT}\n"

  # Verificar se temos a senha
  if [ -z "${mysql_root_password}" ]; then
    printf "${RED} ❌ Senha não foi definida. Não é possível criar o usuário.${GRAY_LIGHT}\n"
    printf "${WHITE} 💻 Execute install_primaria primeiro para criar o usuário.${GRAY_LIGHT}\n"
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

  # Criar diretório home
  sudo mkdir -p /home/deploy
  sudo chown deploy:deploy /home/deploy

  printf "${GREEN} ✅ Usuário deploy criado com sucesso${GRAY_LIGHT}\n"
  return 0
}
