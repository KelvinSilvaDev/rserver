# 🚀 Setup do Repositório GitHub

## ✅ Repositório Criado

**URL:** https://github.com/KelvinSilvaDev/rserver

## 📋 Checklist de Setup Inicial

### 1. Configuração Básica do Repositório

- [x] Repositório criado
- [ ] Descrição adicionada
- [ ] Website (se houver)
- [ ] Topics/tags adicionados
- [ ] README.md atualizado

### 2. Configurações do GitHub

#### Adicionar Descrição e Topics

**Descrição sugerida:**
```
CLI multiplataforma e open-source para gerenciar serviços remotos. Funciona em Linux, macOS e Windows.
```

**Topics sugeridos:**
- `cli`
- `python`
- `server-management`
- `remote-server`
- `systemd`
- `docker`
- `automation`
- `cross-platform`
- `open-source`

### 3. Primeiro Commit e Push

```bash
# Adicionar remote (se ainda não tiver)
git remote add origin https://github.com/KelvinSilvaDev/rserver.git

# Ou se já tiver, atualizar
git remote set-url origin https://github.com/KelvinSilvaDev/rserver.git

# Verificar
git remote -v

# Fazer commit inicial
git add .
git commit -m "feat: initial commit - CLI multiplataforma para gerenciar serviços remotos"

# Push
git branch -M main
git push -u origin main
```

### 4. Configurar GitHub Actions

Os workflows já estão criados em `.github/workflows/`:

- `release.yml` - Releases automáticos
- `homebrew.yml` - Atualização Homebrew

**Configurar secrets (quando necessário):**
- `PYPI_API_TOKEN` - Para publicação no PyPI
- `GITHUB_TOKEN` - Já configurado automaticamente

### 5. Criar Primeiro Release

1. **Criar tag:**
```bash
git tag -a v1.0.0 -m "Release v1.0.0 - Versão inicial"
git push origin v1.0.0
```

2. **Criar release no GitHub:**
   - Vá em "Releases" → "Create a new release"
   - Tag: `v1.0.0`
   - Título: `v1.0.0 - Versão Inicial`
   - Descrição: Copiar conteúdo do `CHANGELOG.md`

### 6. Configurar Homebrew Tap

1. **Criar repositório:** `homebrew-rserver`
   - Nome: `homebrew-rserver`
   - Descrição: "Homebrew tap for RSERVER"

2. **Estrutura:**
```
homebrew-rserver/
└── Formula/
    └── rserver.rb
```

3. **Copiar formula:**
```bash
# Copiar formula do projeto
cp cli/Formula/rserver.rb /path/to/homebrew-rserver/Formula/rserver.rb
```

4. **Atualizar SHA256:**
```bash
# Calcular SHA256 do release
curl -sL https://github.com/KelvinSilvaDev/rserver/archive/v1.0.0.tar.gz | shasum -a 256
```

5. **Atualizar formula com SHA256 e commit:**
```bash
cd /path/to/homebrew-rserver
git add Formula/rserver.rb
git commit -m "Add rserver formula"
git push
```

6. **Instalar:**
```bash
brew tap KelvinSilvaDev/rserver
brew install rserver
```

### 7. Publicar no PyPI (Opcional)

```bash
cd cli

# Instalar ferramentas
pip install build twine

# Construir pacote
python -m build

# Verificar
twine check dist/*

# Testar primeiro (TestPyPI)
twine upload --repository testpypi dist/*

# Publicar (produção)
# Requer token: https://pypi.org/manage/account/token/
export TWINE_USERNAME=__token__
export TWINE_PASSWORD=pypi-xxxxx
twine upload dist/*
```

### 8. Adicionar Badges ao README

Adicionar no topo do `README.md`:

```markdown
![Platform](https://img.shields.io/badge/platform-Linux%20%7C%20macOS%20%7C%20Windows-blue)
![Python](https://img.shields.io/badge/python-3.7+-green)
![License](https://img.shields.io/badge/license-Apache--2.0-orange)
![GitHub release](https://img.shields.io/github/v/release/KelvinSilvaDev/rserver)
![GitHub stars](https://img.shields.io/github/stars/KelvinSilvaDev/rserver?style=social)
```

### 9. Configurar Issues e Discussions

- [ ] Habilitar Issues
- [ ] Habilitar Discussions (opcional)
- [ ] Criar templates de issue
- [ ] Criar template de PR

### 10. Adicionar Arquivos Importantes

- [x] `LICENSE` (Apache-2.0)
- [x] `README.md`
- [x] `CONTRIBUTING.md`
- [x] `CHANGELOG.md`
- [ ] `.gitignore` (verificar se está completo)
- [ ] `CODE_OF_CONDUCT.md` (opcional)

## 🎯 Próximos Passos

1. **Fazer push do código**
2. **Criar primeiro release**
3. **Configurar Homebrew Tap**
4. **Adicionar badges ao README**
5. **Divulgar em comunidades**

## 📚 Documentação Relacionada

- **[COMO-PUBLICAR.md](COMO-PUBLICAR.md)** - Guia completo de publicação
- **[GUIA-DISTRIBUICAO.md](GUIA-DISTRIBUICAO.md)** - Detalhes de distribuição
- **[CONTRIBUTING.md](CONTRIBUTING.md)** - Guia de contribuição

## 🔗 Links Úteis

- **Repositório:** https://github.com/KelvinSilvaDev/rserver
- **Issues:** https://github.com/KelvinSilvaDev/rserver/issues
- **Releases:** https://github.com/KelvinSilvaDev/rserver/releases

---

**Repositório configurado e pronto para uso!** 🚀
