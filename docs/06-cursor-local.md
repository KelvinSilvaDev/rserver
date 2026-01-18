# 💻 Cursor Local vs Remoto

## Problema

Quando você está usando o PC como servidor remoto e também quer codar localmente no WSL2, o comando `cursor .` estava tentando abrir no Mac remoto em vez de abrir localmente no Windows.

**Erro encontrado:**
```
Erro: Execute via SSH do Mac
```

## Solução

A função `cursor()` no `~/.bashrc` foi modificada para detectar automaticamente se você está:

- **Localmente no WSL2**: Abre o Cursor localmente no Windows
- **Remotamente via SSH**: Usa o script `cursor-remote` que abre no Mac remoto

### Mudanças Realizadas

1. ✅ Função `cursor()` atualizada para detectar ambiente local vs remoto
2. ✅ Script `/home/kelvin/bin/cursor` renomeado para `cursor-remote`
3. ✅ Alias removido para dar prioridade à função

## Como Funciona

A função verifica as variáveis de ambiente `SSH_CONNECTION` e `SSH_CLIENT`:

- Se **não** estiverem definidas → Modo **LOCAL** (WSL2)
  - Abre o Cursor diretamente no Windows usando caminhos WSL
- Se estiverem definidas → Modo **REMOTO** (via SSH)
  - Usa o script `cursor-remote` que abre no Mac

## Uso

### Localmente no WSL2 (abre no Windows)

```bash
cd ~/www/estudos/react/react-bits
cursor .
# ou
cursor /caminho/para/projeto
```

### Remotamente via SSH (abre no Mac)

```bash
ssh kelvin@servidor
cd ~/projeto
cursor .  # Abre no Mac via cursor-remote
```

## Recarregar Configuração

Se você já tem um terminal aberto, recarregue o `.bashrc`:

```bash
# Remover função antiga da memória e recarregar
unset -f cursor 2>/dev/null
source ~/.bashrc
```

Ou simplesmente **abra um novo terminal** (mais fácil).

## Verificar se Está Funcionando

```bash
# Verificar se cursor é uma função
type cursor

# Deve mostrar: "cursor is a function"
# Se mostrar "cursor is /home/kelvin/bin/cursor", recarregue o .bashrc
```

## Reverter

Se precisar reverter para o comportamento anterior:

```bash
# Restaurar backup
cp ~/.bashrc.backup ~/.bashrc

# Renomear script de volta
mv ~/bin/cursor-remote ~/bin/cursor

# Recarregar
source ~/.bashrc
```

