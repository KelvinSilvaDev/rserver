# 🌐 RSERVER - Multiplataforma e Open Source

## ✅ O Que Foi Implementado

### 1. Suporte Multiplataforma Completo

- ✅ **Linux**: Totalmente suportado
- ✅ **macOS**: Totalmente suportado  
- ✅ **Windows**: Suportado via PowerShell

### 2. Scripts de Instalação

- ✅ `cli/install.sh` - Linux e macOS (Bash)
- ✅ `cli/install.ps1` - Windows (PowerShell)
- ✅ Detecção automática de plataforma
- ✅ Instalação global ou do usuário

### 3. Detecção de Plataforma

- ✅ Módulo `src/utils/platform.py`
- ✅ Detecção automática de OS
- ✅ Caminhos compatíveis por plataforma
- ✅ Comandos adaptativos

### 4. Documentação Completa

- ✅ **[PLATAFORMAS.md](PLATAFORMAS.md)** - Guia completo multiplataforma
- ✅ **[CONTRIBUTING.md](CONTRIBUTING.md)** - Guia de contribuição
- ✅ **[MULTIPLATAFORMA.md](MULTIPLATAFORMA.md)** - Visão geral
- ✅ Instruções de instalação por plataforma
- ✅ Troubleshooting específico por OS

### 5. Código Adaptativo

- ✅ Comandos específicos por plataforma
- ✅ Detecção automática de OS
- ✅ Caminhos compatíveis (pathlib)
- ✅ Sudo apenas em Unix-like

## 📋 Estrutura Criada

```
rserver/
├── cli/
│   ├── install.sh          # Linux/macOS
│   ├── install.ps1         # Windows
│   └── src/
│       └── utils/
│           └── platform.py # Detecção de plataforma
├── PLATAFORMAS.md          # Guia multiplataforma
├── CONTRIBUTING.md         # Guia de contribuição
├── MULTIPLATAFORMA.md      # Visão geral
└── README-OPEN-SOURCE.md   # Info open-source
```

## 🚀 Como Usar

### Linux

```bash
sudo ./cli/install.sh
rserver --help
```

### macOS

```bash
sudo ./cli/install.sh
rserver --help
```

### Windows

```powershell
.\cli\install.ps1
rserver --help
```

## 🔧 Adaptações por Plataforma

### Comandos Adaptativos

O código detecta automaticamente a plataforma e usa comandos apropriados:

- **Verificar porta**: `ss` (Linux), `lsof` (macOS), `netstat` (Windows)
- **Verificar processo**: `pgrep` (Linux/macOS), `tasklist` (Windows)
- **Sudo**: Apenas em Unix-like (Linux/macOS)

### Configuração Flexível

`services.json` permite comandos específicos por plataforma:

```json
{
  "services": {
    "servico": {
      "start_cmd_linux": ["systemctl", "start"],
      "start_cmd_macos": ["launchctl", "load"],
      "start_cmd_windows": ["net", "start"],
      "start_cmd": ["fallback"]  // Universal
    }
  }
}
```

## 📚 Documentação

### Para Usuários

1. **[PLATAFORMAS.md](PLATAFORMAS.md)** - Instalação por plataforma
2. **[DOCUMENTACAO.md](DOCUMENTACAO.md)** - Documentação completa
3. **[QUICK-START.md](cli/QUICK-START.md)** - Início rápido

### Para Contribuidores

1. **[CONTRIBUTING.md](CONTRIBUTING.md)** - Guia de contribuição
2. **[DEVELOPMENT.md](cli/docs/DEVELOPMENT.md)** - Desenvolvimento
3. **[ARCHITECTURE.md](cli/docs/ARCHITECTURE.md)** - Arquitetura

## 🎯 Princípios Aplicados

### Multiplataforma First

- ✅ Código portável (Python padrão)
- ✅ Detecção automática
- ✅ Comandos adaptativos
- ✅ Caminhos compatíveis

### Open Source Friendly

- ✅ Documentação completa
- ✅ Código organizado
- ✅ Guia de contribuição
- ✅ Testes incluídos

### Fácil de Usar

- ✅ Instalação simples
- ✅ Comandos intuitivos
- ✅ Mensagens claras
- ✅ Exemplos práticos

## ✅ Checklist de Compatibilidade

Ao adicionar novas funcionalidades:

- [ ] Funciona em Linux
- [ ] Funciona em macOS
- [ ] Funciona em Windows
- [ ] Documentação atualizada
- [ ] Testes adicionados
- [ ] Limitações documentadas

## 🔗 Links Rápidos

- **[Instalação Linux/macOS](PLATAFORMAS.md#linux)**
- **[Instalação Windows](PLATAFORMAS.md#windows)**
- **[Contribuindo](CONTRIBUTING.md)**
- **[Documentação Completa](DOCUMENTACAO.md)**

---

**RSERVER agora é verdadeiramente multiplataforma e pronto para open-source!** 🚀
