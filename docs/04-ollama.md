# 🤖 Ollama - Modelos de IA Locais

## O que é Ollama?

Ollama permite rodar Large Language Models (LLMs) localmente, aproveitando sua GPU.

## Modelos Recomendados

| Modelo | Tamanho | VRAM | Uso |
|--------|---------|------|-----|
| `llama3.2` | 2GB | 4GB | Chat geral, rápido |
| `llama3.2:3b` | 2GB | 4GB | Chat geral |
| `codellama` | 4GB | 8GB | Programação |
| `mistral` | 4GB | 8GB | Chat geral, bom |
| `mixtral` | 26GB | 48GB | Muito capaz |
| `deepseek-coder` | 4GB | 8GB | Programação |
| `qwen2.5-coder` | 4GB | 8GB | Programação |

## Baixar Modelos

```bash
# Modelo leve para testes
ollama pull llama3.2

# Modelo para código
ollama pull codellama

# Modelo mais capaz
ollama pull mistral
```

## Usar via Terminal

```bash
# Chat interativo
ollama run llama3.2

# Executar prompt
echo "Explique Docker em 3 linhas" | ollama run llama3.2
```

## Usar via API

```bash
# Listar modelos
curl http://localhost:11434/api/tags

# Gerar resposta
curl http://localhost:11434/api/generate -d '{
  "model": "llama3.2",
  "prompt": "Olá, como você está?",
  "stream": false
}'

# Chat
curl http://localhost:11434/api/chat -d '{
  "model": "llama3.2",
  "messages": [{"role": "user", "content": "Olá!"}],
  "stream": false
}'
```

## Acessar do Notebook Remotamente

### Via Tailscale:

```bash
curl http://100.x.x.x:11434/api/tags
```

### Via SSH Tunnel:

```bash
# No notebook, criar túnel
ssh -L 11434:localhost:11434 kelvin@100.x.x.x

# Agora funciona localmente
curl http://localhost:11434/api/tags
```

## Integrar com VS Code (Continue)

1. Instale a extensão **Continue** no VS Code
2. Configure em `~/.continue/config.json`:

```json
{
  "models": [
    {
      "title": "Ollama Local",
      "provider": "ollama",
      "model": "codellama",
      "apiBase": "http://100.x.x.x:11434"
    }
  ]
}
```

## Verificar GPU

```bash
# Ver se está usando GPU
nvidia-smi

# Ollama usa GPU automaticamente se disponível
ollama run llama3.2 --verbose
```

## Configurar OLLAMA_HOST

Para acessar de outros IPs:

```bash
# Permitir conexões externas
export OLLAMA_HOST=0.0.0.0:11434
ollama serve
```

