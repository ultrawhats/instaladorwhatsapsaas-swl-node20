## 🚀 Instalação Rápida e Segura

### Método Recomendado (Mais Seguro)

```bash
# Baixar e configurar o instalador
bash <(curl -s https://raw.githubusercontent.com/ultrawhats/instaladorwhatsapsaas-swl-node20/main/install.sh)

# OU se já tiver o arquivo install.sh localmente:
chmod +x install.sh && ./install.sh
```

Depois execute:
```bash
cd instaladorwhatsapsaas-swl-node20
sudo ./install_primaria
```

### Método Alternativo (Manual)

```bash
# Instalar git (se necessário)
sudo apt install -y git

# Clonar repositório
git clone https://github.com/ultrawhats/instaladorwhatsapsaas-swl-node20
cd instaladorwhatsapsaas-swl-node20

# Configurar permissões de forma segura
chmod +x install_primaria install_instancia
find . -name "*.sh" -exec chmod +x {} \;

# Executar instalação primária
sudo ./install_primaria
```

## 📝 Instalações Adicionais

Para instalar instâncias adicionais após a primeira instalação:

```bash
cd instaladorwhatsapsaas-swl-node20
sudo ./install_instancia
```

## ⚠️ Nota de Segurança

**NÃO use `chmod -R 777`** - Isso dá permissões de leitura, escrita e execução para todos os usuários, o que é um risco de segurança. O script `install.sh` configura permissões adequadas automaticamente.
