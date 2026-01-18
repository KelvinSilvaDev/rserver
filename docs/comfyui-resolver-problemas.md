# 🔧 Resolver Problemas do ComfyUI

## Problema: Manager bloqueando instalações

**Erro**: "This action is not allowed with this security level configuration"

### Solução:

```bash
# Ajustar configuração de segurança do Manager
./comfyui-fix-manager-security.sh

# Reiniciar o ComfyUI
docker restart comfyui
```

Depois disso, você poderá instalar modelos e nodes pelo Manager sem restrições.

## Problema: Modelos faltando no workflow

**Erro**: "Value not in list: vae_name: 'ae.safetensors' not in [...]"

### Solução 1: Baixar VAE FLUX.1

```bash
./comfyui-download-flux-vae.sh
docker restart comfyui
```

### Solução 2: Baixar modelos HIDream

```bash
./comfyui-download-hidream.sh
docker restart comfyui
```

## Problema: Modelos em subdiretórios

Alguns workflows requerem modelos em subdiretórios específicos:

- **VAE**: `models/vae/ae.safetensors`
- **CLIP t5xxl**: `models/clip/t5/t5xxl_fp8_e4m3fn_scaled.safetensors`
- **UNET**: `models/unet/hidream_i1_full_fp8.safetensors`

Os scripts criam automaticamente os subdiretórios necessários.

## Problema: Modelos não aparecem na interface

1. Verifique se o arquivo está no diretório correto
2. Verifique se o formato está correto (.safetensors, .ckpt, etc.)
3. Reinicie o container: `docker restart comfyui`
4. Limpe o cache do navegador (Ctrl+Shift+R)

## Problema: Custom node não funciona

1. Verifique se foi instalado corretamente: `./comfyui-list-models.sh`
2. Verifique os logs: `docker logs comfyui`
3. Alguns nodes precisam de dependências adicionais:

```bash
# Instalar dependências de um node específico
docker exec comfyui bash -c "cd /app/ComfyUI/custom_nodes/NOME_DO_NODE && pip install -r requirements.txt"
```

## Verificar o que está instalado

```bash
# Listar todos os modelos e nodes
./comfyui-list-models.sh
```

## Acesso direto aos arquivos (Bind Mounts)

Se você está usando bind mounts, pode acessar diretamente pelo Windows Explorer:

1. Navegue até o diretório do ComfyUI no Windows
2. Coloque modelos em:
   - `models/vae/` - VAEs
   - `models/clip/` - CLIP models
   - `models/unet/` - UNET models
   - `models/checkpoints/` - Checkpoints principais
3. Reinicie: `docker restart comfyui`

