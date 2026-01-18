# 🔗 ComfyUI com Bind Mounts (Acesso Direto do Windows)

Se você quer acessar os dados do ComfyUI diretamente pelo Explorer do Windows, você pode usar **bind mounts** ao invés de volumes Docker.

## 📍 Configuração

### Opção 1: Usar um diretório no Windows

1. Crie uma pasta no Windows, por exemplo: `C:\ComfyUI-data`

2. Dentro dessa pasta, crie as subpastas:
   - `models`
   - `output`
   - `input`
   - `custom_nodes`

3. Atualize o `start-server.sh` para usar bind mounts:

```bash
# Ao invés de volumes Docker, usar bind mounts
docker run -d \
    --name comfyui \
    -p 127.0.0.1:8188:8188 \
    --restart always \
    --gpus all \
    -v /mnt/c/ComfyUI-data/models:/app/ComfyUI/models \
    -v /mnt/c/ComfyUI-data/output:/app/ComfyUI/output \
    -v /mnt/c/ComfyUI-data/input:/app/ComfyUI/input \
    -v /mnt/c/ComfyUI-data/custom_nodes:/app/ComfyUI/custom_nodes \
    comfyui:local
```

### Opção 2: Usar a instalação anterior do Windows

Se você quer usar diretamente a pasta da instalação anterior:

```bash
docker run -d \
    --name comfyui \
    -p 127.0.0.1:8188:8188 \
    --restart always \
    --gpus all \
    -v /mnt/c/Users/klvml/Downloads/ComfyUI-Easy-Install/ComfyUI-Easy-Install/ComfyUI/models:/app/ComfyUI/models \
    -v /mnt/c/Users/klvml/Downloads/ComfyUI-Easy-Install/ComfyUI-Easy-Install/ComfyUI/output:/app/ComfyUI/output \
    -v /mnt/c/Users/klvml/Downloads/ComfyUI-Easy-Install/ComfyUI-Easy-Install/ComfyUI/input:/app/ComfyUI/input \
    -v /mnt/c/Users/klvml/Downloads/ComfyUI-Easy-Install/ComfyUI-Easy-Install/ComfyUI/custom_nodes:/app/ComfyUI/custom_nodes \
    comfyui:local
```

## ⚠️ Observações

- **Performance**: Bind mounts podem ser um pouco mais lentos que volumes Docker (especialmente com muitos arquivos pequenos)
- **Permissões**: Certifique-se de que o WSL tem permissão para acessar os diretórios do Windows
- **Caminhos**: Use sempre `/mnt/c/` para acessar o Windows do WSL

## 🔄 Migrar dados existentes

Se você já tem dados nos volumes Docker e quer migrar para bind mounts:

```bash
# 1. Parar container
docker stop comfyui

# 2. Copiar dados dos volumes para o Windows
sudo cp -r /var/lib/docker/volumes/comfyui-models/_data/* /mnt/c/ComfyUI-data/models/
sudo cp -r /var/lib/docker/volumes/comfyui-output/_data/* /mnt/c/ComfyUI-data/output/
sudo cp -r /var/lib/docker/volumes/comfyui-input/_data/* /mnt/c/ComfyUI-data/input/

# 3. Remover container antigo
docker rm comfyui

# 4. Recriar com bind mounts (usando o script atualizado)
./start-server.sh
```

