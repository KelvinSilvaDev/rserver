# 📦 Distribuição de CLIs - Guia Completo

## 🎯 Visão Geral

Este guia explica como distribuir e manter a CLI RSERVER através de diferentes gerenciadores de pacotes e plataformas.

## 🍺 Homebrew (macOS e Linux)

### O Que É Homebrew?

Homebrew é o gerenciador de pacotes mais popular para macOS e Linux. Permite instalar software com um simples comando:

```bash
brew install rserver
```

### Criar Formula do Homebrew

#### 1. Estrutura Básica

Crie um arquivo `Formula/r/rserver.rb`:

```ruby
class Rserver < Formula
  desc "Remote Server Control - CLI multiplataforma para gerenciar serviços remotos"
  homepage "https://github.com/KelvinSilvaDev/rserver"
  url "https://github.com/KelvinSilvaDev/rserver/archive/v1.0.0.tar.gz"
  sha256 "hash_do_arquivo_tar_gz"
  license "MIT"

  depends_on "python@3.9"

  def install
    # Instalar dependências Python
    system "python3", "-m", "pip", "install", "--upgrade", "pip"
    
    # Instalar CLI
    system "python3", "-m", "pip", "install", "--prefix=#{prefix}", "."
    
    # Criar wrapper script
    bin.install "cli/rsctl_new.py" => "rserver"
  end

  test do
    system "#{bin}/rserver", "--version"
  end
end
```

#### 2. Publicar no Homebrew Core (Oficial)

**Requisitos:**
- Projeto open-source com licença
- Pelo menos 20 stars no GitHub
- Usuários ativos
- Documentação completa

**Processo:**
1. Fork do repositório [homebrew-core](https://github.com/Homebrew/homebrew-core)
2. Criar PR com sua formula
3. Aguardar revisão e aprovação

**Documentação:** https://docs.brew.sh/Adding-Software-to-Homebrew

#### 3. Homebrew Tap (Alternativa Mais Fácil)

**Tap próprio** (recomendado para começar):

1. **Criar repositório `homebrew-rserver`**:

```bash
# Criar repositório no GitHub
# Nome: homebrew-rserver
```

2. **Estrutura do repositório**:

```
homebrew-rserver/
└── Formula/
    └── rserver.rb
```

3. **Formula simplificada**:

```ruby
class Rserver < Formula
  desc "Remote Server Control - CLI multiplataforma"
  homepage "https://github.com/KelvinSilvaDev/rserver"
  url "https://github.com/KelvinSilvaDev/rserver/archive/v1.0.0.tar.gz"
  sha256 "hash_aqui"
  license "MIT"

  depends_on "python@3.9"

  def install
    ENV["PYTHONPATH"] = libexec
    system "python3", "-m", "pip", "install", "--prefix=#{libexec}", "."
    bin.install Dir["#{libexec}/bin/*"]
  end

  test do
    system "#{bin}/rserver", "--version"
  end
end
```

4. **Instalar via tap**:

```bash
brew tap KelvinSilvaDev/rserver
brew install rserver
```

### Atualizar Formula

Quando lançar nova versão:

1. Atualizar URL e SHA256 na formula
2. Commit e push
3. Usuários atualizam com: `brew upgrade rserver`

## 🐍 PyPI (Python Package Index)

### Vantagens

- Instalação via `pip install rserver`
- Funciona em todas as plataformas
- Fácil de manter

### Setup

#### 1. Criar `setup.py` ou `pyproject.toml`

**pyproject.toml** (recomendado):

```toml
[build-system]
requires = ["setuptools>=61.0", "wheel"]
build-backend = "setuptools.build_meta"

[project]
name = "rserver"
version = "1.0.0"
description = "Remote Server Control - CLI multiplataforma para gerenciar serviços remotos"
readme = "README.md"
requires-python = ">=3.7"
license = {text = "MIT"}
authors = [
    {name = "Seu Nome", email = "seu@email.com"}
]
keywords = ["cli", "server", "remote", "services", "management"]
classifiers = [
    "Development Status :: 4 - Beta",
    "Intended Audience :: Developers",
    "Intended Audience :: System Administrators",
    "License :: OSI Approved :: MIT License",
    "Programming Language :: Python :: 3",
    "Programming Language :: Python :: 3.7",
    "Programming Language :: Python :: 3.8",
    "Programming Language :: Python :: 3.9",
    "Programming Language :: Python :: 3.10",
    "Programming Language :: Python :: 3.11",
    "Operating System :: OS Independent",
    "Topic :: System :: Systems Administration",
]

[project.scripts]
rserver = "rsctl.cli.commands:main"

[project.urls]
Homepage = "https://github.com/KelvinSilvaDev/rserver"
Documentation = "https://github.com/KelvinSilvaDev/rserver/blob/main/DOCUMENTACAO.md"
Repository = "https://github.com/KelvinSilvaDev/rserver"
Issues = "https://github.com/KelvinSilvaDev/rserver/issues"
```

#### 2. Publicar no PyPI

```bash
# Instalar ferramentas
pip install build twine

# Construir pacote
python -m build

# Verificar
twine check dist/*

# Publicar (teste primeiro)
twine upload --repository testpypi dist/*

# Publicar (produção)
twine upload dist/*
```

**Instalação:**
```bash
pip install rserver
```

## 📦 Outros Gerenciadores

### Snap (Linux)

**snapcraft.yaml**:

```yaml
name: rserver
version: '1.0.0'
summary: Remote Server Control CLI
description: |
  CLI multiplataforma para gerenciar serviços remotos

grade: stable
confinement: strict

apps:
  rserver:
    command: rserver
    plugs:
      - network
      - network-bind

parts:
  rserver:
    plugin: python
    source: .
    python-version: python3
```

**Publicar:**
```bash
snapcraft
snapcraft upload rserver_1.0.0_amd64.snap
```

### Chocolatey (Windows)

**rserver.nuspec**:

```xml
<?xml version="1.0"?>
<package xmlns="http://schemas.microsoft.com/packaging/2015/06/nuspec.xsd">
  <metadata>
    <id>rserver</id>
    <version>1.0.0</version>
    <title>RSERVER</title>
    <authors>Seu Nome</authors>
    <description>Remote Server Control CLI</description>
    <projectUrl>https://github.com/KelvinSilvaDev/rserver</projectUrl>
    <tags>cli server remote management</tags>
  </metadata>
  <files>
    <file src="cli\**\*" target="tools\" />
  </files>
</package>
```

**Publicar:**
```bash
choco pack
choco push rserver.1.0.0.nupkg
```

### Scoop (Windows)

**bucket/rserver.json**:

```json
{
  "version": "1.0.0",
  "description": "Remote Server Control CLI",
  "homepage": "https://github.com/KelvinSilvaDev/rserver",
  "license": "Apache-2.0",
  "url": "https://github.com/KelvinSilvaDev/rserver/releases/download/v1.0.0/rserver-windows.zip",
  "hash": "hash_aqui",
  "bin": "rserver.exe",
  "checkver": "github",
  "autoupdate": {
    "url": "https://github.com/KelvinSilvaDev/rserver/releases/download/v$version/rserver-windows.zip"
  }
}
```

## 🚀 Como CLIs São Divulgadas

### 1. Repositório GitHub

- ✅ README claro e atrativo
- ✅ Badges (plataforma, licença, versão)
- ✅ Releases com changelog
- ✅ Issues e Discussions ativos
- ✅ GitHub Actions para CI/CD

### 2. Documentação

- ✅ Site/documentação online
- ✅ Exemplos de uso
- ✅ Guias de instalação
- ✅ FAQ e troubleshooting

### 3. Comunidade

- ✅ Reddit (r/commandline, r/devops)
- ✅ Hacker News (Show HN)
- ✅ Twitter/X
- ✅ Discord/Slack communities
- ✅ Blog posts e tutoriais

### 4. Listas e Diretórios

- ✅ Awesome lists
- ✅ CLI tools directories
- ✅ Product Hunt
- ✅ Dev.to articles

## 🔧 Como CLIs São Mantidas

### Versionamento

Use [Semantic Versioning](https://semver.org/):

- **MAJOR**: Mudanças incompatíveis
- **MINOR**: Novas funcionalidades (compatível)
- **PATCH**: Correções de bugs

### Releases

1. **Criar tag**:
```bash
git tag -a v1.0.0 -m "Release version 1.0.0"
git push origin v1.0.0
```

2. **Criar release no GitHub**:
   - Título: `v1.0.0`
   - Descrição: Changelog
   - Anexar binários (se houver)

3. **Atualizar gerenciadores**:
   - Homebrew: Atualizar formula
   - PyPI: `twine upload dist/*`
   - Outros: Seguir processo específico

### CI/CD

**GitHub Actions** para automatizar:

```yaml
# .github/workflows/release.yml
name: Release

on:
  release:
    types: [created]

jobs:
  publish:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Publish to PyPI
        run: |
          pip install build twine
          python -m build
          twine upload dist/*
```

### Changelog

Mantenha `CHANGELOG.md`:

```markdown
# Changelog

## [1.0.0] - 2024-01-15

### Added
- Suporte multiplataforma (Linux, macOS, Windows)
- Instalação via Homebrew, PyPI, etc.

### Changed
- Melhorias de performance

### Fixed
- Correção de bugs
```

## 📚 Onde Se Instruir

### Documentação Oficial

1. **Homebrew**
   - https://docs.brew.sh/
   - https://docs.brew.sh/Adding-Software-to-Homebrew
   - https://docs.brew.sh/Formula-Cookbook

2. **PyPI**
   - https://packaging.python.org/
   - https://pypi.org/help/
   - https://twine.readthedocs.io/

3. **Snap**
   - https://snapcraft.io/docs
   - https://snapcraft.io/docs/snapcraft-overview

4. **Chocolatey**
   - https://docs.chocolatey.org/
   - https://docs.chocolatey.org/en-us/create/create-packages

### Recursos Úteis

- **Awesome CLI**: https://github.com/agarrharr/awesome-cli-apps
- **CLI Guidelines**: https://clig.dev/
- **Semantic Versioning**: https://semver.org/
- **Keep a Changelog**: https://keepachangelog.com/

### Exemplos de CLIs Bem Distribuídas

- **gh** (GitHub CLI): Homebrew, apt, yum, etc.
- **docker**: Múltiplos gerenciadores
- **kubectl**: Homebrew, apt, yum, etc.
- **terraform**: Homebrew, apt, yum, etc.

## 🎯 Estratégia Recomendada

### Fase 1: Começar Simples

1. **GitHub Releases** com binários
2. **Homebrew Tap próprio** (fácil de criar)
3. **PyPI** (se for Python puro)

### Fase 2: Expandir

4. **Homebrew Core** (quando tiver tração)
5. **Snap** (para Linux)
6. **Chocolatey/Scoop** (para Windows)

### Fase 3: Manter

7. **CI/CD** para releases automáticos
8. **Changelog** atualizado
9. **Documentação** sempre atualizada

## 📝 Checklist para Publicação

- [ ] Versão definida (semver)
- [ ] Changelog atualizado
- [ ] README atualizado
- [ ] Licença definida
- [ ] Testes passando
- [ ] Binários compilados (se necessário)
- [ ] Release no GitHub criado
- [ ] Formula/package atualizado
- [ ] Documentação de instalação atualizada

---

**RSERVER pronto para distribuição multiplataforma!** 🚀
