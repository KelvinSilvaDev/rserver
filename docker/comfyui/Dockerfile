FROM python:3.10-slim

# Instalar dependências do sistema
RUN apt-get update && apt-get install -y \
    git \
    wget \
    libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

# Criar diretório de trabalho
WORKDIR /app

# Clonar ComfyUI
RUN git clone https://github.com/comfyanonymous/ComfyUI.git /app/ComfyUI

WORKDIR /app/ComfyUI

# Instalar PyTorch com suporte CUDA primeiro (mais rápido)
RUN pip install --no-cache-dir torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121

# Instalar dependências do ComfyUI
RUN pip install --no-cache-dir -r requirements.txt

# Fixar versão do huggingface-hub para compatibilidade com transformers
RUN pip install --no-cache-dir 'huggingface-hub>=0.34.0,<1.0'

# Criar diretórios para volumes
RUN mkdir -p /app/ComfyUI/models /app/ComfyUI/output /app/ComfyUI/input

# Expor porta
EXPOSE 8188

# Comando para iniciar ComfyUI
# --listen 0.0.0.0 permite acesso externo
CMD ["python", "main.py", "--listen", "0.0.0.0", "--port", "8188"]

