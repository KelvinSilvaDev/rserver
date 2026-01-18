# 🌐 RSERVER - Multiplataforma e Open Source

## 🎯 Visão Geral

RSERVER é uma CLI **open-source** e **multiplataforma** projetada para funcionar em qualquer sistema operacional moderno.

## ✅ Plataformas Suportadas

| Plataforma | Status | Versão Mínima | Notas |
|------------|--------|---------------|-------|
| **Linux** | ✅ Totalmente Suportado | Qualquer distribuição moderna | Ubuntu, Debian, RHEL, Arch, Fedora, etc. |
| **macOS** | ✅ Totalmente Suportado | 10.14+ (Mojave) | Intel e Apple Silicon (M1/M2) |
| **Windows** | ✅ Suportado | Windows 10+ | PowerShell 5.1+ ou PowerShell Core |

## 🚀 Instalação Rápida

### Linux

```bash
# Instalação global
sudo ./cli/install.sh

# Instalação do usuário (sem sudo)
INSTALL_DIR=~/.local/bin ./cli/install.sh
```

### macOS

```bash
# Instalação global
sudo ./cli/install.sh

# Instalação do usuário (sem sudo)
INSTALL_DIR=~/.local/bin ./cli/install.sh
```

### Windows

```powershell
# Executar no PowerShell
.\cli\install.ps1
```

> 📖 **Instruções detalhadas: [PLATAFORMAS.md](PLATAFORMAS.md)**

## 🔧 Compatibilidade

### Comandos do Sistema

RSERVER detecta automaticamente a plataforma e usa comandos apropriados:

| Funcionalidade | Linux | macOS | Windows |
|----------------|-------|-------|---------|
| Verificar processo | `pgrep` | `pgrep` | `tasklist` / PowerShell |
| Verificar porta | `ss -lntp` | `lsof` | `netstat` |
| Gerenciar serviços | `systemctl` | `launchctl` | `sc` / PowerShell |
| Elevação | `sudo` | `sudo` | UAC |

### Tipos de Serviços

Nem todos os tipos funcionam em todas as plataformas:

- ✅ **docker**: Funciona em todas (se Docker instalado)
- ✅ **http**: Funciona em todas
- ✅ **port**: Funciona em todas (comandos diferentes)
- ✅ **process**: Funciona em todas (comandos diferentes)
- ⚠️ **systemd**: Apenas Linux
- ⚠️ **launchctl**: Apenas macOS
- ⚠️ **Windows Services**: Apenas Windows

## 📝 Configuração Multiplataforma

Você pode definir comandos específicos por plataforma em `services.json`:

```json
{
  "services": {
    "meu-servico": {
      "display_name": "Meu Serviço",
      "check_type": "process",
      "process_name": "meu-processo",
      "start_cmd_linux": ["systemctl", "start", "servico"],
      "start_cmd_macos": ["launchctl", "load", "/path/to/plist"],
      "start_cmd_windows": ["net", "start", "Servico"],
      "start_cmd": ["comando", "universal"]  // Fallback
    }
  }
}
```

## 🤝 Contribuindo

RSERVER é open-source! Contribuições são bem-vindas.

### Como Contribuir

1. **Fork o repositório**
2. **Crie uma branch**: `git checkout -b feature/minha-feature`
3. **Faça suas alterações**
4. **Teste em múltiplas plataformas** (se possível)
5. **Commit**: `git commit -m "feat: adiciona feature X"`
6. **Push**: `git push origin feature/minha-feature`
7. **Abra um Pull Request**

> 📖 **Guia completo: [CONTRIBUTING.md](CONTRIBUTING.md)**

### Testando Multiplataforma

Se sua alteração afeta compatibilidade:

- ✅ Teste em Linux (se possível)
- ✅ Teste em macOS (se possível)
- ✅ Teste em Windows (se possível)
- ✅ Documente limitações (se houver)

## 📚 Documentação

- **[PLATAFORMAS.md](PLATAFORMAS.md)** - Instalação e compatibilidade detalhada
- **[CONTRIBUTING.md](CONTRIBUTING.md)** - Guia de contribuição
- **[DOCUMENTACAO.md](DOCUMENTACAO.md)** - Documentação completa
- **[README.md](README.md)** - Visão geral

## 🎯 Princípios de Design

### Multiplataforma First

- ✅ Código portável (Python padrão)
- ✅ Detecção automática de plataforma
- ✅ Comandos adaptativos
- ✅ Caminhos compatíveis (pathlib)

### Open Source Friendly

- ✅ Documentação completa
- ✅ Código bem organizado
- ✅ Testes incluídos
- ✅ Guia de contribuição claro

### Fácil de Usar

- ✅ Instalação simples
- ✅ Comandos intuitivos
- ✅ Mensagens claras
- ✅ Exemplos práticos

## 🔍 Verificação de Plataforma

O código detecta automaticamente a plataforma:

```python
from src.utils.platform import PlatformDetector

if PlatformDetector.is_windows():
    # Código Windows
elif PlatformDetector.is_macos():
    # Código macOS
else:
    # Código Linux
```

## 📋 Checklist para Contribuidores

Ao contribuir, certifique-se de:

- [ ] Código funciona em Linux
- [ ] Código funciona em macOS (se aplicável)
- [ ] Código funciona em Windows (se aplicável)
- [ ] Documentação atualizada
- [ ] Testes adicionados (se aplicável)
- [ ] Limitações documentadas (se houver)

## 🌟 Roadmap

- [ ] CI/CD multiplataforma (GitHub Actions)
- [ ] Testes automatizados em todas plataformas
- [ ] Suporte para mais tipos de serviços
- [ ] Plugin system
- [ ] API REST

---

**RSERVER - Para todos, em qualquer lugar!** 🚀
