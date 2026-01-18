# ⚡ Quick Start - RSERVER

Guia rápido para começar a usar o RSERVER.

## 🚀 Instalação Rápida

```bash
# 1. Instalar CLI
sudo ./cli/install.sh

# 2. Verificar instalação
rserver --help
```

## 📋 Comandos Essenciais

### Listar Serviços

```bash
rserver list
```

### Ver Status

```bash
# Todos os serviços
rserver status

# Serviço específico
rserver status ollama
```

### Iniciar Serviços

```bash
# Todos os serviços
rserver start all

# Serviços específicos
rserver start ssh ollama webui

# Todos exceto alguns
rserver start all --exclude comfyui
```

### Parar Serviços

```bash
# Todos os serviços
rserver stop all

# Serviço específico
rserver stop webui

# Todos exceto alguns
rserver stop all --exclude ssh
```

## 🎯 Casos de Uso Comuns

### Iniciar Apenas Serviços Essenciais

```bash
rserver start ssh ollama webui
```

### Economizar Recursos (Parar Serviços Pesados)

```bash
rserver stop comfyui cloudflare
```

### Reiniciar um Serviço

```bash
rserver stop ollama
rserver start ollama
```

### Verificar Antes de Iniciar Tudo

```bash
rserver status
rserver start all
```

## 📚 Mais Informação

- [Documentação Completa](README.md)
- [Instalação Remota](INSTALL-REMOTE.md)
