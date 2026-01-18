# 🔧 Comandos Git para Primeiro Commit

Execute estes comandos no seu terminal:

## 1. Configurar Git (se ainda não configurou globalmente)

```bash
# Configurar globalmente (recomendado)
git config --global user.name "Kelvin Silva"
git config --global user.email "seu-email@exemplo.com"

# OU configurar apenas para este repositório
git config user.name "Kelvin Silva"
git config user.email "seu-email@exemplo.com"
```

## 2. Verificar se já está configurado

```bash
git config user.name
git config user.email
```

## 3. Adicionar arquivos ao staging

```bash
cd /home/kelvin/www/poc/remote-server
git add .
```

## 4. Criar commit

```bash
git commit -m "feat: initial commit - CLI multiplataforma para gerenciar serviços remotos"
```

## 5. Renomear branch para main (se necessário)

```bash
git branch -M main
```

## 6. Verificar remote

```bash
git remote -v
```

Se não tiver o remote configurado:

```bash
git remote add origin https://github.com/KelvinSilvaDev/rserver.git
```

## 7. Fazer push

```bash
git push -u origin main
```

## 🐛 Se der erro de autenticação

Se pedir usuário/senha, você pode:

**Opção 1: Usar Personal Access Token (Recomendado)**
1. Vá em GitHub → Settings → Developer settings → Personal access tokens → Tokens (classic)
2. Crie um novo token com permissão `repo`
3. Use o token como senha quando pedir

**Opção 2: Usar SSH (Mais seguro)**
```bash
# Mudar remote para SSH
git remote set-url origin git@github.com:KelvinSilvaDev/rserver.git

# Fazer push
git push -u origin main
```

## ✅ Verificar se funcionou

```bash
# Ver último commit
git log --oneline -1

# Ver status
git status
```

---

**Depois do push, acesse:** https://github.com/KelvinSilvaDev/rserver
