# 🔐 Como Adicionar Token do PyPI no GitHub

Este guia explica como adicionar o token do PyPI como secret no GitHub para publicação automática.

## 📋 Passo a Passo

### 1. Acessar Secrets do GitHub

1. Vá para o repositório: https://github.com/KelvinSilvaDev/rserver
2. Clique em **Settings** (Configurações)
3. No menu lateral, clique em **Secrets and variables** → **Actions**

### 2. Adicionar Novo Secret

1. Clique em **New repository secret**
2. **Name**: `PYPI_API_TOKEN`
3. **Secret**: Cole o token do PyPI que você recebeu (exemplo de formato: `pypi-AgEIcHlwaS5vcmcCJDUw...`)
4. Clique em **Add secret**

### 3. Verificar

O secret `PYPI_API_TOKEN` agora deve aparecer na lista de secrets. Ele será usado automaticamente pelo workflow `.github/workflows/release.yml` quando você criar uma release.

## ✅ Pronto!

Agora, quando você criar uma release no GitHub, o workflow publicará automaticamente no PyPI!

## 🔄 Como Funciona

1. Você cria uma release no GitHub (ex: v1.0.0)
2. O workflow `.github/workflows/release.yml` é acionado
3. O workflow faz build do pacote
4. O workflow publica no PyPI usando o token secreto
5. Usuários podem instalar com: `pip install rserver`

## 🔒 Segurança

- O token nunca será exposto nos logs
- Apenas workflows autorizados podem usar o secret
- Você pode revogar o token a qualquer momento no PyPI

## 📚 Próximos Passos

Depois de adicionar o token:
1. Criar uma release no GitHub
2. O workflow publicará automaticamente no PyPI
3. Testar: `pip install rserver`
