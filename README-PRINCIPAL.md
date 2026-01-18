# 🚀 RSERVER - Remote Server Control

> **CLI multiplataforma e open-source para gerenciar serviços remotos**

[![Platform](https://img.shields.io/badge/platform-Linux%20%7C%20macOS%20%7C%20Windows-blue)]()
[![Python](https://img.shields.io/badge/python-3.7+-green)]()
[![License](https://img.shields.io/badge/license-MIT-orange)]()

## ✨ Características

- 🌐 **Multiplataforma**: Funciona em Linux, macOS e Windows
- 🚀 **Fácil de Usar**: Comandos intuitivos e simples
- ⚡ **Rápido**: Cache inteligente para performance
- 🔧 **Configurável**: JSON simples para configurar serviços
- 📚 **Bem Documentado**: Documentação completa e clara
- 🤝 **Open Source**: Contribuições são bem-vindas!

## 🚀 Instalação Rápida

### Linux / macOS

```bash
sudo ./cli/install.sh
```

### Windows

```powershell
.\cli\install.ps1
```

> 📖 **Instruções detalhadas: [PLATAFORMAS.md](PLATAFORMAS.md)**

## 📋 Uso Básico

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

## 📚 Documentação

- **[📖 Documentação Completa](DOCUMENTACAO.md)** - Guia completo
- **[🌐 Multiplataforma](PLATAFORMAS.md)** - Instalação por plataforma
- **[🤝 Contribuindo](CONTRIBUTING.md)** - Guia de contribuição
- **[📑 Índice](INDICE.md)** - Navegação rápida

## 🌐 Plataformas Suportadas

| Plataforma | Status | Instalação |
|------------|--------|------------|
| **Linux** | ✅ Totalmente Suportado | `sudo ./cli/install.sh` |
| **macOS** | ✅ Totalmente Suportado | `sudo ./cli/install.sh` |
| **Windows** | ✅ Suportado | `.\cli\install.ps1` |

## 🤝 Contribuindo

Contribuições são bem-vindas! Veja nosso [Guia de Contribuição](CONTRIBUTING.md).

### Formas de Contribuir

- 🐛 Reportar bugs
- 💡 Sugerir melhorias
- 📝 Melhorar documentação
- 💻 Adicionar funcionalidades
- 🌐 Adicionar suporte para novas plataformas

## 📦 Estrutura do Projeto

```
rserver/
├── cli/                    # CLI principal
│   ├── src/               # Código fonte
│   ├── tests/             # Testes
│   └── docs/              # Documentação técnica
├── docs/                   # Documentação do projeto
├── PLATAFORMAS.md         # Suporte multiplataforma
├── CONTRIBUTING.md        # Guia de contribuição
└── DOCUMENTACAO.md        # Documentação completa
```

## 🎯 Casos de Uso

- Gerenciar serviços em servidores remotos
- Iniciar/parar serviços de forma organizada
- Verificar status de múltiplos serviços
- Automatizar inicialização de serviços
- Gerenciar serviços em diferentes plataformas

## 📝 Licença

[Adicione sua licença aqui]

## 🙏 Agradecimentos

Obrigado a todos os contribuidores!

---

**RSERVER - Gerenciamento de Serviços Remotos para Todos** 🚀
