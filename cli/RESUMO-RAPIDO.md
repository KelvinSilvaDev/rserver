# ⚡ Resumo Rápido - Como Funciona

## 🎯 Em 30 Segundos

A CLI é um **gerenciador de serviços** que:
1. **Lê configuração** (`services.json`) → Sabe quais serviços existem
2. **Executa comandos** (start/stop) → Inicia ou para serviços
3. **Verifica status** → Checa se está rodando (com cache)
4. **Mostra feedback** → Cores e símbolos para fácil entendimento

## 📋 Comandos Básicos

```bash
rserver list              # Ver serviços disponíveis
rserver status            # Ver o que está rodando
rserver start ssh         # Iniciar um serviço
rserver start all         # Iniciar todos
rserver stop webui        # Parar um serviço
```

## 🔄 Fluxo Simples

```
Você → rserver start ssh
  ↓
CLI valida se "ssh" existe
  ↓
Verifica se já está rodando (usa cache)
  ↓
Se não, executa comando de start
  ↓
Aguarda 2 segundos
  ↓
Verifica se iniciou
  ↓
Mostra: ✅ SSH Server iniciado
```

## 💾 Cache (Por que é rápido)

- **Primeira vez**: Executa comando (pode ser lento)
- **Próximas 5s**: Retorna do cache (instantâneo!)
- **Após 5s**: Verifica novamente

## 🎨 Tipos de Verificação

Cada serviço pode verificar status de formas diferentes:

- **systemd**: `systemctl is-active`
- **docker**: `docker ps` (verifica container)
- **http**: `curl` (faz requisição)
- **port**: `ss` (verifica porta)
- **process**: `pgrep` (verifica processo)

## 📝 Configuração

Tudo em `services.json`:

```json
{
  "services": {
    "ssh": {
      "display_name": "SSH Server",
      "check_type": "systemd",
      "start_cmd": ["service", "ssh", "start"]
    }
  }
}
```

## 🎯 Resumo Final

**A CLI é um "orquestrador inteligente" que:**
- Sabe como gerenciar cada tipo de serviço
- Usa cache para ser rápido
- Mostra feedback claro
- Registra tudo em logs

**Simples assim!** 🚀
