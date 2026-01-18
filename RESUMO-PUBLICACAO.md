# 🚀 Resumo Rápido - Como Publicar

## ✅ O que já está pronto

1. ✅ Pacote Python configurado e testado
2. ✅ Arquivos do Homebrew Tap criados
3. ✅ Workflows do GitHub Actions configurados
4. ✅ Documentação completa criada

## 📦 PyPI - 3 Passos Simples

### 1. Adicionar Token no GitHub

1. Vá em: https://github.com/KelvinSilvaDev/rserver/settings/secrets/actions
2. Clique em **New repository secret**
3. Nome: `PYPI_API_TOKEN`
4. Valor: Cole o token que você recebeu
5. Salve

📖 **Guia detalhado**: `COMO-ADICIONAR-PYPI-TOKEN.md`

### 2. Criar Release no GitHub

1. Vá em: https://github.com/KelvinSilvaDev/rserver/releases/new
2. Tag: `v1.0.0`
3. Título: `v1.0.0`
4. Descrição: Copie do CHANGELOG.md
5. Clique em **Publish release**

### 3. Pronto! 🎉

O workflow publicará automaticamente no PyPI. Em alguns minutos, usuários poderão instalar com:

```bash
pip install rserver
```

## 🍺 Homebrew - 5 Passos Simples

### 1. Criar Repositório no GitHub

1. Vá em: https://github.com/new
2. **Nome**: `homebrew-rserver` (IMPORTANTE: deve começar com `homebrew-`)
3. **Público**: Sim
4. **NÃO** adicione README, .gitignore ou licença
5. Clique em **Create repository**

### 2. Copiar Arquivos

Os arquivos já estão prontos em `homebrew-rserver/`:

```bash
cd /Users/kelvin/www/pocs/cli/rserver/homebrew-rserver
# Os arquivos já estão aqui!
```

### 3. Calcular SHA256 e Configurar

```bash
cd homebrew-rserver
./setup.sh 1.0.0
```

Isso vai:
- Calcular o SHA256 automaticamente
- Atualizar a formula com a versão e hash corretos

### 4. Commit e Push

```bash
git init
git add .
git commit -m "Initial commit: Add rserver formula"
git branch -M main
git remote add origin git@github.com:KelvinSilvaDev/homebrew-rserver.git
git push -u origin main
```

### 5. Testar

```bash
brew tap KelvinSilvaDev/rserver
brew install rserver
rserver --version
```

📖 **Guia detalhado**: `homebrew-rserver/COMO-CRIAR-REPOSITORIO.md`

## 🔄 Atualizações Futuras

Depois da primeira vez, tudo será automático:

1. **PyPI**: Crie uma release → Publica automaticamente
2. **Homebrew**: Crie uma release → Atualiza automaticamente via workflow

## 📚 Documentação Completa

- **PyPI Token**: `COMO-ADICIONAR-PYPI-TOKEN.md`
- **Homebrew Tap**: `homebrew-rserver/COMO-CRIAR-REPOSITORIO.md`
- **Guia Completo**: `cli/GUIA-PUBLICACAO.md`

## ❓ Dúvidas Frequentes

### O homebrew-rserver precisa ser forkado?

**Não!** É um repositório completamente novo e vazio. Você cria do zero.

### Pode ser todo em branco?

**Sim!** Você pode criar o repositório vazio e depois adicionar os arquivos que já estão prontos em `homebrew-rserver/`.

### Preciso fazer tudo manualmente toda vez?

**Não!** Depois da primeira vez, os workflows do GitHub Actions fazem tudo automaticamente quando você cria uma release.

---

**Tudo pronto para publicar!** 🚀
