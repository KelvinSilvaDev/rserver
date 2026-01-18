# 🎯 Sugestões de Nomes para a CLI

## 📝 Análise do Nome Atual

**rsctl** = Remote Server Control
- ✅ Curto
- ❌ Não é muito intuitivo
- ❌ Pode ser difícil de lembrar
- ❌ Não soa "amigável"

## 🎨 Opções de Nomes

### Opção 1: `rserver` ⭐ (Recomendado)
**Remote Server**

```bash
rserver list
rserver start all
rserver status
```

**Prós:**
- ✅ Intuitivo e claro
- ✅ Fácil de lembrar
- ✅ Soa profissional
- ✅ Curto (7 letras)

**Contras:**
- ⚠️ Pode conflitar se já existe comando `rserver`

---

### Opção 2: `servctl`
**Service Control**

```bash
servctl list
servctl start all
servctl status
```

**Prós:**
- ✅ Claro sobre o propósito (controlar serviços)
- ✅ Fácil de digitar
- ✅ Soa profissional

**Contras:**
- ⚠️ Um pouco genérico

---

### Opção 3: `rsc`
**Remote Server Control** (abreviação)

```bash
rsc list
rsc start all
rsc status
```

**Prós:**
- ✅ Muito curto (3 letras)
- ✅ Rápido de digitar
- ✅ Mantém significado original

**Contras:**
- ❌ Não é muito intuitivo
- ❌ Pode ser difícil de lembrar

---

### Opção 4: `remctl`
**Remote Control**

```bash
remctl list
remctl start all
remctl status
```

**Prós:**
- ✅ Claro sobre controle remoto
- ✅ Fácil de lembrar
- ✅ Soa profissional

**Contras:**
- ⚠️ Pode ser confundido com "remove control"

---

### Opção 5: `serverctl`
**Server Control**

```bash
serverctl list
serverctl start all
serverctl status
```

**Prós:**
- ✅ Muito claro
- ✅ Auto-explicativo

**Contras:**
- ❌ Mais longo (10 letras)
- ❌ Mais lento de digitar

---

### Opção 6: `serv`
**Service** (super curto)

```bash
serv list
serv start all
serv status
```

**Prós:**
- ✅ Muito curto (4 letras)
- ✅ Rápido de digitar
- ✅ Simples

**Contras:**
- ❌ Muito genérico
- ❌ Pode conflitar com outros comandos

---

## 🏆 Top 3 Recomendações

### 1. `rserver` ⭐⭐⭐
**Melhor equilíbrio entre clareza e brevidade**

### 2. `servctl` ⭐⭐
**Claro sobre propósito, profissional**

### 3. `remctl` ⭐
**Boa alternativa, foca em "remoto"**

## 🔧 Como Mudar o Nome

### Opção A: Alias Simples

Criar alias no `~/.bashrc` ou `~/.zshrc`:

```bash
alias rserver='rsctl'
# ou
alias servctl='rsctl'
```

### Opção B: Renomear Completamente

1. Renomear `rsctl.py` → `rserver.py`
2. Atualizar `install.sh` para criar link `rserver`
3. Atualizar documentação

### Opção C: Múltiplos Nomes

Manter ambos funcionando:

```bash
rsctl → (comando original)
rserver → (alias/nome novo)
```

## 💡 Minha Recomendação

**Usar `rserver`** porque:
- É intuitivo ("remote server")
- É fácil de lembrar
- Soa profissional
- Não é muito longo
- É claro sobre o propósito

## 🎯 Implementação Rápida

Posso criar um script que:
1. Cria alias `rserver` apontando para `rsctl`
2. Atualiza `install.sh` para instalar como `rserver`
3. Mantém `rsctl` funcionando (compatibilidade)

**Quer que eu implemente alguma dessas opções?**
