# 🎛️ RSERVER - Remote Server Control

CLI profissional para gerenciar serviços do servidor remoto.

## 🚀 Instalação

```bash
# Instalar globalmente
sudo ./cli/install.sh

# Verificar
rserver --help
```

## 📋 Comandos Básicos

```bash
# Listar serviços
rserver list

# Ver status
rserver status

# Iniciar serviços
rserver start ssh ollama
rserver start all

# Parar serviços
rserver stop webui
rserver stop all
```

## 📚 Documentação Completa

Para documentação completa, veja:
- **[Documentação Principal](../DOCUMENTACAO.md)** - Guia completo
- **[Quick Start](QUICK-START.md)** - Início rápido
- **[Instalação Remota](INSTALL-REMOTE.md)** - Instalar em servidor Linux

## ⚙️ Configuração

Edite `cli/services.json` para configurar serviços.

## 🐛 Troubleshooting

```bash
# Validar configuração
rserver validate

# Ver logs
tail -f logs/rserver.log

# Modo verboso
rserver --verbose start ssh
```

---

**Para mais informações, consulte [DOCUMENTACAO.md](../DOCUMENTACAO.md)**
