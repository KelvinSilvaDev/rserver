# 🎯 Alternativas para Baixar Modelos (SEM DERRUBAR NADA)

## ✅ Situação Atual
- ✅ ComfyUI está funcionando
- ✅ Bind mount ativo: `C:\Users\klvml\Downloads\ComfyUI-Easy-Install\ComfyUI-Easy-Install\ComfyUI\models`
- ⚠️ Manager com segurança `normal` (bloqueia downloads)
- ❌ Modelos faltando: VAE, CLIP HIDream, UNET

---

## 📋 OPÇÃO 1: Baixar Manualmente pelo Windows (MAIS SEGURO)

### Vantagens:
- ✅ Não mexe no container
- ✅ Não precisa reiniciar nada
- ✅ Você controla o que baixa

### Passos:

1. **Abrir Explorer do Windows:**
   ```
   C:\Users\klvml\Downloads\ComfyUI-Easy-Install\ComfyUI-Easy-Install\ComfyUI\models
   ```

2. **Baixar VAE FLUX.1:**
   - Acesse: https://huggingface.co/black-forest-labs/FLUX.1-dev/tree/main/vae
   - Clique em `ae.safetensors`
   - Baixe e coloque em: `models\vae\ae.safetensors`

3. **Baixar Modelos HIDream:**
   - Acesse: https://huggingface.co/black-forest-labs/HIDream/tree/main
   - Baixe os arquivos e coloque em:
     - `models\clip\clip_l_hidream.safetensors`
     - `models\clip\clip_g_hidream.safetensors`
     - `models\clip\llama_3.1_8b_instruct_fp8_scaled.safetensors`
     - `models\clip\t5\t5xxl_fp8_e4m3fn_scaled.safetensors` (criar pasta `t5` primeiro)
     - `models\unet\hidream_i1_full_fp8.safetensors` (criar pasta `unet` primeiro)

4. **Reiniciar apenas o ComfyUI:**
   ```bash
   docker restart comfyui
   ```

---

## 📋 OPÇÃO 2: Ajustar Segurança do Manager (SEM RECRIAR)

### Vantagens:
- ✅ Permite usar o Manager pela interface web
- ✅ Não precisa baixar manualmente

### Passos:

1. **Editar arquivo de configuração:**
   - Abrir no Windows:
     ```
     C:\Users\klvml\Downloads\ComfyUI-Easy-Install\ComfyUI-Easy-Install\ComfyUI\user\__manager\config.ini
     ```
   - Mudar a linha:
     ```
     security_level = normal
     ```
   - Para:
     ```
     security_level = weak
     ```

2. **Reiniciar apenas o ComfyUI:**
   ```bash
   docker restart comfyui
   ```

3. **Usar o Manager pela interface web** para baixar os modelos

---

## 📋 OPÇÃO 3: Usar Scripts de Download (SEM RECRIAR)

### Vantagens:
- ✅ Automatizado
- ✅ Funciona mesmo com HuggingFace bloqueando

### Limitações:
- ⚠️ HuggingFace pode estar exigindo autenticação
- ⚠️ Pode precisar de token

### Passos:

1. **Configurar token do HuggingFace (se necessário):**
   ```bash
   docker exec -it comfyui bash
   huggingface-cli login
   # Cole seu token do HuggingFace
   exit
   ```

2. **Executar scripts:**
   ```bash
   ./comfyui-download-flux-vae.sh
   ./comfyui-download-hidream.sh
   ```

3. **Reiniciar apenas o ComfyUI:**
   ```bash
   docker restart comfyui
   ```

---

## 📋 OPÇÃO 4: Usar wget/curl Direto no Container

### Vantagens:
- ✅ Não precisa de token
- ✅ Funciona mesmo com restrições

### Passos:

1. **Entrar no container:**
   ```bash
   docker exec -it comfyui bash
   ```

2. **Baixar modelos manualmente:**
   ```bash
   cd /app/ComfyUI/models
   
   # Criar diretórios
   mkdir -p vae clip/t5 unet
   
   # Baixar VAE (tentar diferentes URLs)
   cd vae
   wget https://huggingface.co/black-forest-labs/FLUX.1-dev/resolve/main/vae/ae.safetensors
   
   # Baixar CLIP models
   cd ../clip
   wget https://huggingface.co/black-forest-labs/HIDream/resolve/main/clip/clip_l_hidream.safetensors
   wget https://huggingface.co/black-forest-labs/HIDream/resolve/main/clip/clip_g_hidream.safetensors
   wget https://huggingface.co/black-forest-labs/HIDream/resolve/main/clip/llama_3.1_8b_instruct_fp8_scaled.safetensors
   
   cd t5
   wget https://huggingface.co/black-forest-labs/HIDream/resolve/main/clip/t5xxl_fp8_e4m3fn_scaled.safetensors
   
   # Baixar UNET
   cd ../../unet
   wget https://huggingface.co/black-forest-labs/HIDream/resolve/main/unet/hidream_i1_full_fp8.safetensors
   
   exit
   ```

3. **Reiniciar apenas o ComfyUI:**
   ```bash
   docker restart comfyui
   ```

---

## 🎯 RECOMENDAÇÃO

**Para você que não quer derrubar nada:**

1. **OPÇÃO 1 (Manual pelo Windows)** - Mais seguro, você controla tudo
2. **OPÇÃO 2 (Ajustar Manager)** - Se quiser usar a interface web depois

**Evite:**
- ❌ Recriar container
- ❌ Reconstruir imagem
- ❌ Modificar Dockerfile

---

## 📝 Estrutura de Diretórios Necessária

```
models/
├── vae/
│   └── ae.safetensors
├── clip/
│   ├── clip_l_hidream.safetensors
│   ├── clip_g_hidream.safetensors
│   ├── llama_3.1_8b_instruct_fp8_scaled.safetensors
│   └── t5/
│       └── t5xxl_fp8_e4m3fn_scaled.safetensors
└── unet/
    └── hidream_i1_full_fp8.safetensors
```

---

## ⚠️ IMPORTANTE

- **NÃO** recrie o container
- **NÃO** reconstrua a imagem
- **APENAS** reinicie: `docker restart comfyui`
- Os arquivos baixados no Windows aparecem automaticamente no container (bind mount)


