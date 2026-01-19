# 🔧 Correção: Usuário Deploy Não Criado

## Problema Identificado

O erro `su: user deploy does not exist or the user entry does not contain all the required fields` ocorria quando:
1. O usuário executava `install_instancia` sem executar `install_primaria` primeiro
2. A função `system_create_user` falhava silenciosamente
3. O script tentava usar o usuário `deploy` antes de verificá-lo

## Correções Implementadas

### 1. Melhorias na Função `system_create_user`
- ✅ Verifica se o usuário já existe antes de criar
- ✅ Valida se a senha foi definida
- ✅ Tratamento de erros adequado
- ✅ Criação do diretório home se necessário
- ✅ Mensagens de feedback claras

### 2. Novo Arquivo: `lib/_user_check.sh`
Criado arquivo com funções auxiliares:
- `check_deploy_user()` - Verifica se o usuário existe
- `ensure_deploy_user()` - Garante que o usuário existe ou tenta criá-lo

### 3. Validações em Todas as Funções
Adicionadas verificações do usuário `deploy` antes de usar em:
- ✅ `backend_set_env()`
- ✅ `backend_node_dependencies()`
- ✅ `backend_node_build()`
- ✅ `backend_db_migrate()`
- ✅ `backend_db_seed()`
- ✅ `backend_start_pm2()`
- ✅ `frontend_set_env()`
- ✅ `frontend_node_dependencies()`
- ✅ `frontend_node_build()`
- ✅ `frontend_start_pm2()`
- ✅ `system_git_clone()`

### 4. Validação no `install_instancia`
- ✅ Verifica se o usuário `deploy` existe antes de continuar
- ✅ Tenta criar o usuário automaticamente se não existir
- ✅ Exibe mensagem clara se não conseguir criar

## Como Usar

### Primeira Instalação (Cria o usuário deploy)
```bash
sudo ./install_primaria
```

### Instalações Adicionais (Verifica/cria usuário se necessário)
```bash
sudo ./install_instancia
```

O script agora verifica automaticamente se o usuário existe e tenta criá-lo se necessário.

## Solução Rápida

Se o erro ainda ocorrer, execute manualmente:

```bash
# Verificar se o usuário existe
id deploy

# Se não existir, criar manualmente (substitua SENHA pela senha desejada)
sudo useradd -m -p $(openssl passwd -crypt "SENHA") -s /bin/bash deploy
sudo usermod -aG sudo deploy
sudo mkdir -p /home/deploy
sudo chown deploy:deploy /home/deploy
```

## Arquivos Modificados

- `lib/_system.sh` - Função `system_create_user` melhorada
- `lib/_backend.sh` - Validações adicionadas
- `lib/_frontend.sh` - Validações adicionadas
- `lib/_user_check.sh` - **NOVO** - Funções de verificação
- `lib/manifest.sh` - Inclusão do novo arquivo
- `install_instancia` - Validação do usuário antes de continuar
- `install_primaria` - Tratamento de erro melhorado
