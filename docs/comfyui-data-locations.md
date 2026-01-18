# 📦 Localização dos Dados do ComfyUI

## 📍 Onde estão os dados no Docker?

Os dados do ComfyUI são armazenados em **volumes Docker** que persistem mesmo quando o container é removido.

### Volumes Docker:

| Volume | Caminho no Host | Caminho no Container | Conteúdo |
|--------|----------------|---------------------|----------|
| `comfyui-models` | `/var/lib/docker/volumes/comfyui-models/_data` | `/app/ComfyUI/models` | Checkpoints, VAE, LoRA, ControlNet, etc. |
| `comfyui-output` | `/var/lib/docker/volumes/comfyui-output/_data` | `/app/ComfyUI/output` | Imagens geradas |
| `comfyui-input` | `/var/lib/docker/volumes/comfyui-input/_data` | `/app/ComfyUI/input` | Imagens de entrada |

### Estrutura do diretório `models/`:

```
models/
├── checkpoints/          # Modelos principais (.safetensors, .ckpt)
├── vae/                  # Modelos VAE
├── loras/                # LoRA models
├── controlnet/           # ControlNet models
├── clip/                 # CLIP models
├── embeddings/           # Textual inversions
├── upscale_models/       # Modelos de upscale
└── ...
```

## 🔄 Como migrar dados de uma instalação anterior?

### Opção 1: Usar o script de migração (Recomendado)

```bash
# Execute o script passando o caminho da instalação anterior
./migrate-comfyui-data.sh /caminho/para/comfyui/anterior

# Exemplos:
./migrate-comfyui-data.sh ~/ComfyUI
./migrate-comfyui-data.sh /mnt/c/Users/seu-usuario/ComfyUI
```

O script irá:
- ✅ Copiar automaticamente `models/`, `output/`, `input/` e `custom_nodes/`
- ✅ Preservar permissões e estrutura de diretórios
- ✅ Mostrar progresso da cópia

### Opção 2: Copiar manualmente

```bash
# 1. Encontrar o caminho do volume
docker volume inspect comfyui-models --format '{{.Mountpoint}}'

# 2. Copiar modelos (exemplo)
sudo cp -r /caminho/anterior/ComfyUI/models/* /var/lib/docker/volumes/comfyui-models/_data/

# 3. Copiar outputs
sudo cp -r /caminho/anterior/ComfyUI/output/* /var/lib/docker/volumes/comfyui-output/_data/

# 4. Copiar inputs
sudo cp -r /caminho/anterior/ComfyUI/input/* /var/lib/docker/volumes/comfyui-input/_data/
```

### Opção 3: Usar docker cp (com container rodando)

```bash
# 1. Copiar do host para o container
docker cp /caminho/anterior/ComfyUI/models/. comfyui:/app/ComfyUI/models/
docker cp /caminho/anterior/ComfyUI/output/. comfyui:/app/ComfyUI/output/
docker cp /caminho/anterior/ComfyUI/input/. comfyui:/app/ComfyUI/input/
```

## 📂 Acessar dados diretamente

### Ver o que tem nos volumes:

```bash
# Listar modelos
sudo ls -lh /var/lib/docker/volumes/comfyui-models/_data/checkpoints/

# Ver outputs gerados
sudo ls -lh /var/lib/docker/volumes/comfyui-output/_data/

# Ver inputs
sudo ls -lh /var/lib/docker/volumes/comfyui-input/_data/
```

### Adicionar modelos manualmente:

```bash
# Copiar um checkpoint para o volume
sudo cp meu-modelo.safetensors /var/lib/docker/volumes/comfyui-models/_data/checkpoints/

# Reiniciar container para carregar
docker restart comfyui
```

## 🔍 Verificar tamanho dos volumes:

```bash
# Ver tamanho de cada volume
docker system df -v | grep comfyui
```

## 💡 Dicas:

1. **Backup**: Os volumes Docker persistem mesmo removendo o container
2. **Espaço**: Modelos podem ser grandes (GB), verifique espaço em disco
3. **Permissões**: Se tiver problemas, use `sudo` para acessar `/var/lib/docker/volumes/`
4. **Reiniciar**: Após copiar dados, reinicie o container: `docker restart comfyui`

