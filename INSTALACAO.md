# 📦 Guia de Instalação

## 🚀 Instalação Rápida (Recomendado)

### Opção 1: Comando One-Liner Seguro

```bash
bash <(curl -s https://raw.githubusercontent.com/ultrawhats/instaladorwhatsapsaas-swl-node20/main/install.sh) && cd instaladorwhatsapsaas-swl-node20 && sudo ./install_primaria
```

Este comando:
- ✅ Instala git automaticamente se necessário
- ✅ Clona o repositório
- ✅ Configura permissões de forma segura (não usa 777)
- ✅ Verifica se tudo está correto
- ✅ Executa a instalação primária

### Opção 2: Passo a Passo

```bash
# 1. Baixar e configurar
bash <(curl -s https://raw.githubusercontent.com/ultrawhats/instaladorwhatsapsaas-swl-node20/main/install.sh)

# 2. Entrar no diretório
cd instaladorwhatsapsaas-swl-node20

# 3. Executar instalação primária
sudo ./install_primaria
```

### Opção 3: Manual (Se não tiver curl)

```bash
# Instalar git
sudo apt install -y git

# Clonar repositório
git clone https://github.com/ultrawhats/instaladorwhatsapsaas-swl-node20
cd instaladorwhatsapsaas-swl-node20

# Configurar permissões de forma segura
chmod +x install_primaria install_instancia
find . -name "*.sh" -exec chmod +x {} \;

# Executar instalação
sudo ./install_primaria
```

## 📝 Instalações Adicionais

Após a primeira instalação, para instalar novas instâncias:

```bash
cd instaladorwhatsapsaas-swl-node20
sudo ./install_instancia
```

## ⚠️ Por que não usar `chmod -R 777`?

O comando `chmod -R 777` é **muito inseguro** porque:

1. **Dá permissões totais para todos**: Qualquer usuário no sistema pode ler, modificar e executar todos os arquivos
2. **Risco de segurança**: Arquivos sensíveis (como o arquivo `config` com senhas) ficam acessíveis
3. **Violação de boas práticas**: Vai contra o princípio de menor privilégio

### Permissões Seguras

O script `install.sh` configura:
- **755** para diretórios (leitura, escrita, execução para owner; leitura e execução para outros)
- **644** para arquivos (leitura e escrita para owner; leitura para outros)
- **755** para scripts executáveis (leitura, escrita, execução para owner; leitura e execução para outros)
- **700** para arquivo `config` (apenas owner pode ler, escrever e executar)

## 🔒 Segurança

- O arquivo `config` com senhas é criado com permissões `700` (apenas root pode acessar)
- Scripts são executáveis apenas para quem precisa
- Validações de entrada previnem erros e vulnerabilidades

## ❓ Problemas Comuns

### Erro: "Permission denied"
```bash
# Solução: Dar permissão de execução
chmod +x install_primaria install_instancia
```

### Erro: "git: command not found"
```bash
# Solução: Instalar git
sudo apt update && sudo apt install -y git
```

### Erro: "Dependências faltando"
```bash
# Solução: Execute install_primaria primeiro
sudo ./install_primaria
```
