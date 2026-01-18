# 🛠️ Gerenciando Modelos e Custom Nodes no ComfyUI

Como o ComfyUI está rodando em Docker, você tem algumas opções para gerenciar modelos e custom nodes:

## 🎯 Solução Recomendada: ComfyUI Manager

O **ComfyUI Manager** é um custom node que permite gerenciar tudo diretamente pela interface web do ComfyUI.

### Instalação

```bash
./comfyui-install-manager.sh
```

Depois, reinicie o container:
```bash
docker restart comfyui
```

### Como usar

1. Acesse a interface web do ComfyUI
2. Você verá um novo menu **"Manager"** na interface
3. Através do Manager você pode:
   - ✅ Instalar custom nodes com um clique
   - ✅ Baixar modelos diretamente (HuggingFace, CivitAI, etc.)
   - ✅ Atualizar nodes instalados
   - ✅ Ver dependências e instalar automaticamente

## 📥 Scripts Auxiliares

Se preferir usar linha de comando, temos scripts auxiliares:

### 1. Baixar Modelos

```bash
# Sintaxe: ./comfyui-download-model.sh <tipo> <nome> [url]
./comfyui-download-model.sh checkpoint realisticVisionV60B1_v60B1.safetensors https://huggingface.co/...
./comfyui-download-model.sh lora my-lora.safetensors https://civitai.com/...
```

**Tipos disponíveis:**
- `checkpoint` - Modelos principais
- `vae` - Modelos VAE
- `lora` - LoRA models
- `controlnet` - ControlNet models
- `clip` - CLIP models
- `embedding` - Textual inversions
- `upscale` - Modelos de upscale

### 2. Instalar Custom Nodes

```bash
# Sintaxe: ./comfyui-install-node.sh <url_do_repositorio> [nome]
./comfyui-install-node.sh https://github.com/ltdrdata/ComfyUI-Manager.git
./comfyui-install-node.sh https://github.com/WASasquatch/was-node-suite-comfyui.git
```

### 3. Listar Modelos e Nodes

```bash
./comfyui-list-models.sh
```

## 📁 Acesso Direto aos Arquivos (Bind Mounts)

Se você está usando **bind mounts** (configurado no `start-server.sh`), você pode:

### Acessar pelo Windows Explorer

1. Abra o Explorer do Windows
2. Navegue até o diretório do ComfyUI (ex: `C:\Users\klvml\Downloads\ComfyUI-Easy-Install\...`)
3. Você verá as pastas:
   - `models/` - Coloque modelos aqui
   - `custom_nodes/` - Coloque custom nodes aqui
   - `output/` - Imagens geradas
   - `input/` - Imagens de entrada

### Estrutura de diretórios

```
models/
├── checkpoints/      # Modelos principais (.safetensors, .ckpt)
├── vae/              # Modelos VAE
├── loras/            # LoRA models
├── controlnet/       # ControlNet models
├── clip/             # CLIP models
├── embeddings/       # Textual inversions
└── upscale_models/   # Modelos de upscale

custom_nodes/
├── ComfyUI-Manager/  # Manager (instalado via script)
├── was-node-suite/   # Outros nodes...
└── ...
```

### Baixar manualmente

1. Baixe o modelo/node do site (HuggingFace, CivitAI, GitHub, etc.)
2. Coloque no diretório correto no Windows
3. Reinicie o container: `docker restart comfyui`

## 🔄 Atualizar Custom Nodes

### Via Manager (Recomendado)
Use a interface web do Manager para atualizar nodes.

### Via Script
```bash
# Atualizar um node específico
docker exec comfyui bash -c "cd /app/ComfyUI/custom_nodes/NOME_DO_NODE && git pull"

# Atualizar todos os nodes
docker exec comfyui bash -c "cd /app/ComfyUI/custom_nodes && for dir in */; do cd \"\$dir\" && git pull && cd ..; done"
```

## 🐛 Resolver Problemas

### Modelo não aparece na interface

1. Verifique se o arquivo está no diretório correto
2. Verifique se o formato está correto (.safetensors, .ckpt, etc.)
3. Reinicie o container: `docker restart comfyui`
4. Limpe o cache do navegador

### Custom node não funciona

1. Verifique se foi instalado corretamente
2. Verifique se há dependências faltando (veja a documentação do node)
3. Verifique os logs: `docker logs comfyui`
4. Alguns nodes podem precisar de dependências Python adicionais

### Instalar dependências de um node

```bash
# Se o node tiver requirements.txt
docker exec comfyui bash -c "cd /app/ComfyUI/custom_nodes/NOME_DO_NODE && pip install -r requirements.txt"
```

## 📚 Recursos Úteis

- **ComfyUI Manager**: https://github.com/ltdrdata/ComfyUI-Manager
- **Custom Nodes populares**: https://github.com/WASasquatch/ComfyUI_Comfyroll_CustomNodes
- **Modelos HuggingFace**: https://huggingface.co/models?library=diffusers
- **Modelos CivitAI**: https://civitai.com/

## 💡 Dicas

1. **Use o Manager**: É a forma mais fácil de gerenciar tudo
2. **Backup**: Se usar bind mounts, faça backup das pastas `models/` e `custom_nodes/`
3. **Organização**: Mantenha os modelos organizados por tipo
4. **Espaço em disco**: Modelos podem ser grandes (2-7GB cada), monitore o espaço

