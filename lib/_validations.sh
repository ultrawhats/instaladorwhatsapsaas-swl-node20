#!/bin/bash
#
# Validation functions

#######################################
# Validates if a port is available
# Arguments:
#   $1 - Port number
# Returns:
#   0 if port is available, 1 otherwise
#######################################
validate_port() {
  local port=$1
  
  if ! [[ "$port" =~ ^[0-9]+$ ]]; then
    printf "${RED} ❌ Porta inválida: ${port}${GRAY_LIGHT}\n"
    return 1
  fi
  
  if [ "$port" -lt 1 ] || [ "$port" -gt 65535 ]; then
    printf "${RED} ❌ Porta deve estar entre 1 e 65535${GRAY_LIGHT}\n"
    return 1
  fi
  
  if netstat -tuln 2>/dev/null | grep -q ":${port} " || ss -tuln 2>/dev/null | grep -q ":${port} "; then
    printf "${RED} ❌ Porta ${port} já está em uso${GRAY_LIGHT}\n"
    return 1
  fi
  
  return 0
}

#######################################
# Validates URL format
# Arguments:
#   $1 - URL to validate
# Returns:
#   0 if valid, 1 otherwise
#######################################
validate_url() {
  local url=$1
  
  if [ -z "$url" ]; then
    printf "${RED} ❌ URL não pode estar vazia${GRAY_LIGHT}\n"
    return 1
  fi
  
  # Remove protocolo se presente
  url=$(echo "$url" | sed 's|^https\?://||')
  url=${url%%/*}
  
  # Validar formato básico de domínio
  if ! [[ "$url" =~ ^[a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?(\.[a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?)*$ ]]; then
    printf "${RED} ❌ Formato de URL inválido: ${url}${GRAY_LIGHT}\n"
    return 1
  fi
  
  return 0
}

#######################################
# Validates instance name (for new instances)
# Arguments:
#   $1 - Instance name
# Returns:
#   0 if valid, 1 otherwise
#######################################
validate_instance_name() {
  local name=$1
  
  if [ -z "$name" ]; then
    printf "${RED} ❌ Nome da instância não pode estar vazio${GRAY_LIGHT}\n"
    return 1
  fi
  
  # Validar que contém apenas letras minúsculas, números e underscore
  if ! [[ "$name" =~ ^[a-z0-9_]+$ ]]; then
    printf "${RED} ❌ Nome da instância deve conter apenas letras minúsculas, números e underscore${GRAY_LIGHT}\n"
    return 1
  fi
  
  # Verificar se a instância já existe
  if [ -d "/home/deploy/${name}" ]; then
    printf "${RED} ❌ Instância ${name} já existe${GRAY_LIGHT}\n"
    return 1
  fi
  
  return 0
}

#######################################
# Validates instance name format (without checking existence)
# Arguments:
#   $1 - Instance name
# Returns:
#   0 if valid, 1 otherwise
#######################################
validate_instance_name_format() {
  local name=$1
  
  if [ -z "$name" ]; then
    printf "${RED} ❌ Nome da instância não pode estar vazio${GRAY_LIGHT}\n"
    return 1
  fi
  
  # Validar que contém apenas letras minúsculas, números e underscore
  if ! [[ "$name" =~ ^[a-z0-9_]+$ ]]; then
    printf "${RED} ❌ Nome da instância deve conter apenas letras minúsculas, números e underscore${GRAY_LIGHT}\n"
    return 1
  fi
  
  return 0
}

#######################################
# Validates if instance exists
# Arguments:
#   $1 - Instance name
# Returns:
#   0 if exists, 1 otherwise
#######################################
validate_instance_exists() {
  local name=$1
  
  if [ -z "$name" ]; then
    printf "${RED} ❌ Nome da instância não pode estar vazio${GRAY_LIGHT}\n"
    return 1
  fi
  
  if [ ! -d "/home/deploy/${name}" ]; then
    printf "${RED} ❌ Instância ${name} não encontrada${GRAY_LIGHT}\n"
    return 1
  fi
  
  return 0
}

#######################################
# Validates password
# Arguments:
#   $1 - Password
# Returns:
#   0 if valid, 1 otherwise
#######################################
validate_password() {
  local password=$1
  
  if [ -z "$password" ]; then
    printf "${RED} ❌ Senha não pode estar vazia${GRAY_LIGHT}\n"
    return 1
  fi
  
  if [ ${#password} -lt 8 ]; then
    printf "${RED} ❌ Senha deve ter pelo menos 8 caracteres${GRAY_LIGHT}\n"
    return 1
  fi
  
  # Verificar se contém caracteres especiais (não recomendado conforme instrução)
  if [[ "$password" =~ [^a-zA-Z0-9] ]]; then
    printf "${YELLOW} ⚠️  Aviso: Senha contém caracteres especiais. Isso pode causar problemas.${GRAY_LIGHT}\n"
  fi
  
  return 0
}

#######################################
# Validates if required commands are installed
# Arguments:
#   None
# Returns:
#   0 if all installed, 1 otherwise
#######################################
validate_dependencies() {
  local missing_deps=()
  
  command -v node >/dev/null 2>&1 || missing_deps+=("nodejs")
  command -v npm >/dev/null 2>&1 || missing_deps+=("npm")
  command -v pm2 >/dev/null 2>&1 || missing_deps+=("pm2")
  command -v docker >/dev/null 2>&1 || missing_deps+=("docker")
  command -v nginx >/dev/null 2>&1 || missing_deps+=("nginx")
  command -v certbot >/dev/null 2>&1 || missing_deps+=("certbot")
  command -v psql >/dev/null 2>&1 || missing_deps+=("postgresql")
  
  if [ ${#missing_deps[@]} -gt 0 ]; then
    printf "${YELLOW} ⚠️  Dependências faltando: ${missing_deps[*]}${GRAY_LIGHT}\n"
    printf "${WHITE} 💻 Execute install_primaria primeiro para instalar todas as dependências${GRAY_LIGHT}\n"
    return 1
  fi
  
  return 0
}

#######################################
# Validates git URL
# Arguments:
#   $1 - Git URL
# Returns:
#   0 if valid, 1 otherwise
#######################################
validate_git_url() {
  local url=$1
  
  if [ -z "$url" ]; then
    printf "${RED} ❌ URL do Git não pode estar vazia${GRAY_LIGHT}\n"
    return 1
  fi
  
  if ! [[ "$url" =~ ^https?://.*\.git$ ]] && ! [[ "$url" =~ ^git@.*:.*\.git$ ]]; then
    printf "${RED} ❌ URL do Git inválida. Deve ser uma URL HTTP/HTTPS ou SSH${GRAY_LIGHT}\n"
    return 1
  fi
  
  return 0
}
