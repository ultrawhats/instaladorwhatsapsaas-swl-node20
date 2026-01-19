#!/bin/bash
#
# Script de instalação inicial seguro
# Este script baixa e configura o instalador com permissões adequadas
#
# Uso:
#   bash <(curl -s https://raw.githubusercontent.com/ultrawhats/instaladorwhatsapsaas-swl-node20/main/install.sh)
#   OU
#   ./install.sh

set -e  # Sair em caso de erro

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Variáveis
REPO_URL="https://github.com/ultrawhats/instaladorwhatsapsaas-swl-node20"
INSTALL_DIR="instaladorwhatsapsaas-swl-node20"

echo -e "${GREEN}🚀 Iniciando instalação do instalador Whaticket...${NC}\n"

# Verificar se está rodando como root (não recomendado, mas necessário para algumas operações)
if [ "$EUID" -eq 0 ]; then 
   echo -e "${YELLOW}⚠️  Aviso: Este script não deve ser executado como root diretamente.${NC}"
   echo -e "${YELLOW}   Use sudo apenas quando necessário.${NC}\n"
fi

# Verificar se git está instalado
if ! command -v git &> /dev/null; then
    echo -e "${YELLOW}📦 Instalando git...${NC}"
    sudo apt update -qq
    sudo apt install -y git
    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ Erro ao instalar git${NC}"
        exit 1
    fi
    echo -e "${GREEN}✅ Git instalado com sucesso${NC}\n"
else
    echo -e "${GREEN}✅ Git já está instalado${NC}\n"
fi

# Verificar se o diretório já existe
if [ -d "$INSTALL_DIR" ]; then
    echo -e "${YELLOW}⚠️  Diretório $INSTALL_DIR já existe.${NC}"
    read -p "Deseja remover e clonar novamente? (s/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Ss]$ ]]; then
        echo -e "${YELLOW}🗑️  Removendo diretório existente...${NC}"
        rm -rf "$INSTALL_DIR"
    else
        echo -e "${GREEN}✅ Usando diretório existente${NC}\n"
        cd "$INSTALL_DIR"
        if [ -f "install_primaria" ]; then
            echo -e "${GREEN}✅ Instalador encontrado. Execute: sudo ./install_primaria${NC}"
        fi
        exit 0
    fi
fi

# Clonar repositório
echo -e "${GREEN}📥 Clonando repositório...${NC}"
if git clone "$REPO_URL" "$INSTALL_DIR"; then
    echo -e "${GREEN}✅ Repositório clonado com sucesso${NC}\n"
else
    echo -e "${RED}❌ Erro ao clonar repositório${NC}"
    exit 1
fi

# Entrar no diretório
cd "$INSTALL_DIR"

# Configurar permissões de forma segura
echo -e "${GREEN}🔒 Configurando permissões de forma segura...${NC}"

# Dar permissão de execução apenas aos scripts necessários
chmod +x install_primaria install_instancia

# Configurar permissões adequadas para diretórios e arquivos
find . -type d -exec chmod 755 {} \; 2>/dev/null || true
find . -type f -exec chmod 644 {} \; 2>/dev/null || true

# Scripts devem ser executáveis
find . -name "*.sh" -exec chmod +x {} \; 2>/dev/null || true
chmod +x install_primaria install_instancia 2>/dev/null || true

# O arquivo config será criado com permissões restritas pelo próprio instalador
echo -e "${GREEN}✅ Permissões configuradas${NC}\n"

# Verificar se os scripts principais existem
if [ ! -f "install_primaria" ] || [ ! -f "install_instancia" ]; then
    echo -e "${RED}❌ Scripts de instalação não encontrados${NC}"
    exit 1
fi

# Verificar se os scripts são executáveis
if [ ! -x "install_primaria" ] || [ ! -x "install_instancia" ]; then
    echo -e "${YELLOW}⚠️  Scripts não são executáveis. Corrigindo...${NC}"
    chmod +x install_primaria install_instancia
fi

echo -e "${GREEN}✅ Instalação do instalador concluída!${NC}\n"
echo -e "${GREEN}📋 Próximos passos:${NC}"
echo -e "   ${YELLOW}1.${NC} Para primeira instalação:"
echo -e "      ${GREEN}sudo ./install_primaria${NC}\n"
echo -e "   ${YELLOW}2.${NC} Para instalações adicionais:"
echo -e "      ${GREEN}sudo ./install_instancia${NC}\n"
