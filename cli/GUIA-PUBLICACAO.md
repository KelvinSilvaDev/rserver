# 🚀 Guia de Publicação - RSERVER CLI

Este guia explica como publicar o RSERVER nos gerenciadores de pacotes.

## ✅ Preparação Completa

Todos os arquivos necessários foram preparados:

- ✅ `pyproject.toml` - Configuração do pacote Python
- ✅ `setup.py` - Script de instalação
- ✅ `MANIFEST.in` - Arquivos a incluir no pacote
- ✅ `Formula/rserver.rb` - Formula do Homebrew
- ✅ Workflows do GitHub Actions configurados
- ✅ Documentação de instalação criada

## 📦 Publicação no PyPI

### Pré-requisitos

1. **Conta no PyPI**: Crie em https://pypi.org/account/register/
2. **API Token**: Gere em https://pypi.org/manage/account/token/
3. **Adicionar Secret no GitHub**: 
   - Vá em Settings → Secrets and variables → Actions
   - Adicione `PYPI_API_TOKEN` com seu token

### Passo a Passo

#### 1. Testar Build Localmente

```bash
cd cli
python3 -m pip install --upgrade build twine
python3 -m build
python3 -m twine check dist/*
```

#### 2. Testar no TestPyPI (Opcional)

```bash
python3 -m twine upload --repository testpypi dist/*
```

Teste a instalação:
```bash
pip install --index-url https://test.pypi.org/simple/ rserver
```

#### 3. Publicar no PyPI

**Opção A: Manual**

```bash
python3 -m twine upload dist/*
```

**Opção B: Automático (Recomendado)**

1. Crie uma release no GitHub:
   - Vá em Releases → Create a new release
   - Tag: `v1.0.0`
   - Título: `v1.0.0`
   - Descrição: Changelog

2. O workflow `.github/workflows/release.yml` publicará automaticamente

### Verificação

Após publicar, teste a instalação:

```bash
pip install rserver
rserver --version
```

## 🍺 Publicação no Homebrew

### Pré-requisitos

1. **Criar repositório `homebrew-rserver`**:
   - Vá em https://github.com/new
   - Nome: `homebrew-rserver`
   - Descrição: "Homebrew tap for RSERVER"
   - Público

2. **Estrutura do repositório**:
   ```
   homebrew-rserver/
   └── Formula/
       └── rserver.rb
   ```

### Passo a Passo

#### 1. Criar Repositório

```bash
# Criar repositório no GitHub primeiro
mkdir homebrew-rserver
cd homebrew-rserver
git init
mkdir Formula
```

#### 2. Copiar Formula

```bash
# Copiar formula do repositório principal
cp ../rserver/cli/Formula/rserver.rb Formula/
```

#### 3. Calcular SHA256

```bash
# Baixar release e calcular hash
VERSION="1.0.0"
URL="https://github.com/KelvinSilvaDev/rserver/archive/v${VERSION}.tar.gz"
curl -sL "$URL" | shasum -a 256
```

#### 4. Atualizar Formula

Edite `Formula/rserver.rb`:
- Atualize `url` com a versão correta
- Atualize `sha256` com o hash calculado

#### 5. Commit e Push

```bash
git add Formula/rserver.rb
git commit -m "Add rserver formula"
git branch -M main
git remote add origin git@github.com:KelvinSilvaDev/homebrew-rserver.git
git push -u origin main
```

#### 6. Automatizar (Opcional)

O workflow `.github/workflows/homebrew.yml` atualizará automaticamente quando você criar uma release no GitHub.

### Instalação

Usuários podem instalar com:

```bash
brew tap KelvinSilvaDev/rserver
brew install rserver
```

## 🔄 Processo de Atualização

### Para Nova Versão

1. **Atualizar versão**:
   - `cli/pyproject.toml`: `version = "1.1.0"`
   - `cli/setup.py`: `version="1.1.0"`
   - `cli/rsctl/__init__.py`: `__version__ = "1.1.0"`
   - `cli/rsctl/cli/parser.py`: `version='%(prog)s 1.1.0'`

2. **Atualizar CHANGELOG.md**

3. **Commit e Tag**:
   ```bash
   git add .
   git commit -m "Release v1.1.0"
   git tag v1.1.0
   git push origin main --tags
   ```

4. **Criar Release no GitHub**:
   - Isso acionará os workflows automaticamente

5. **Atualizar Homebrew Manualmente** (se workflow não funcionar):
   ```bash
   # Calcular novo SHA256
   VERSION="1.1.0"
   URL="https://github.com/KelvinSilvaDev/rserver/archive/v${VERSION}.tar.gz"
   SHA=$(curl -sL "$URL" | shasum -a 256 | cut -d' ' -f1)
   
   # Atualizar formula
   cd homebrew-rserver
   sed -i '' "s|url \".*\"|url \"https://github.com/KelvinSilvaDev/rserver/archive/v${VERSION}.tar.gz\"|" Formula/rserver.rb
   sed -i '' "s|sha256 \".*\"|sha256 \"${SHA}\"|" Formula/rserver.rb
   git add Formula/rserver.rb
   git commit -m "Update rserver to v${VERSION}"
   git push
   ```

## 📋 Checklist de Publicação

### Antes de Publicar

- [ ] Versão atualizada em todos os arquivos
- [ ] CHANGELOG.md atualizado
- [ ] README.md atualizado
- [ ] Testes passando (se houver)
- [ ] Build testado localmente
- [ ] Twine check passou

### Publicação

- [ ] PyPI: Token configurado no GitHub Secrets
- [ ] PyPI: Release criada no GitHub (ou upload manual)
- [ ] Homebrew: Repositório `homebrew-rserver` criado
- [ ] Homebrew: Formula atualizada com SHA256 correto
- [ ] Homebrew: Commit e push realizados

### Pós-Publicação

- [ ] Testar instalação via `pip install rserver`
- [ ] Testar instalação via `brew tap` + `brew install`
- [ ] Verificar se comandos funcionam
- [ ] Atualizar documentação se necessário
- [ ] Anunciar em redes sociais/comunidades

## 🐛 Troubleshooting

### Erro ao publicar no PyPI

- Verifique se o token está correto
- Verifique se a versão já existe (PyPI não permite re-publicar)
- Use `--skip-existing` se necessário

### Erro no Homebrew

- Verifique se o SHA256 está correto
- Verifique se a URL do release está acessível
- Teste localmente: `brew install --build-from-source Formula/rserver.rb`

### Workflows não executam

- Verifique se os secrets estão configurados
- Verifique os logs do workflow em Actions
- Verifique se a release foi criada corretamente

## 📚 Recursos

- [PyPI Documentation](https://packaging.python.org/)
- [Homebrew Formula Cookbook](https://docs.brew.sh/Formula-Cookbook)
- [Semantic Versioning](https://semver.org/)
- [Keep a Changelog](https://keepachangelog.com/)

---

**Pronto para publicar!** 🚀
