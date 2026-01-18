# 🚀 Guia de Publicação - RSERVER

## 📦 Opções de Distribuição

### 1. Homebrew (Recomendado para Começar) 🍺

**Mais fácil e popular para macOS/Linux**

#### Tap Próprio (Recomendado)

1. **Criar repositório**: `homebrew-rserver`
2. **Copiar formula**: `cli/Formula/rserver.rb`
3. **Atualizar URL e SHA256**
4. **Publicar**

**Instalação:**
```bash
brew tap KelvinSilvaDev/rserver
brew install rserver
```

**Vantagens:**
- ✅ Fácil de criar
- ✅ Controle total
- ✅ Atualizações rápidas

### 2. PyPI (Python Package Index) 🐍

**Funciona em todas plataformas**

**Publicar:**
```bash
cd cli
pip install build twine
python -m build
twine upload dist/*
```

**Instalação:**
```bash
pip install rserver
```

**Vantagens:**
- ✅ Funciona em todas plataformas
- ✅ Fácil de manter
- ✅ Atualização simples

### 3. GitHub Releases 📦

**Binários pré-compilados**

1. Criar release no GitHub
2. Anexar binários para cada plataforma
3. Usuários baixam e instalam manualmente

## 🎯 Estratégia Recomendada

### Começar (Fase 1)

1. **GitHub Releases** - Binários
2. **Homebrew Tap** - Fácil de criar
3. **PyPI** - Python puro

### Expandir (Fase 2)

4. **Homebrew Core** - Quando tiver tração
5. **Snap/Chocolatey** - Plataformas específicas

## 📚 Documentação Completa

- **[GUIA-DISTRIBUICAO.md](../GUIA-DISTRIBUICAO.md)** - Guia completo
- **[DISTRIBUICAO.md](../DISTRIBUICAO.md)** - Detalhes técnicos

## 🔗 Links Úteis

- **Homebrew**: https://docs.brew.sh/
- **PyPI**: https://packaging.python.org/
- **CLI Guidelines**: https://clig.dev/
