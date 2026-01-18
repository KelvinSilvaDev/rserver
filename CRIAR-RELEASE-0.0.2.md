# 🚀 Criar Release 0.0.2

Este guia explica como criar o release 0.0.2 com a estrutura correta.

## ✅ O que foi feito

1. ✅ Versões atualizadas para 0.0.2 em todos os arquivos
2. ✅ Build testado e funcionando
3. ✅ Estrutura `rsctl/` está correta

## 📋 Passos para criar o release

### 1. Commit das mudanças

```bash
cd /Users/kelvin/www/pocs/cli/rserver

# Adicionar todas as mudanças
git add .

# Commit
git commit -m "Release 0.0.2: Fix structure and prepare for Homebrew"

# Push
git push origin main
```

### 2. Criar tag

```bash
# Criar tag
git tag v0.0.2

# Push tag
git push origin v0.0.2
```

### 3. Criar release no GitHub

1. Vá em: https://github.com/KelvinSilvaDev/rserver/releases/new
2. **Tag**: `v0.0.2`
3. **Título**: `v0.0.2`
4. **Descrição**:
```markdown
## v0.0.2

### Fixed
- Corrigida estrutura do pacote (rsctl/ em vez de src/)
- Corrigido setup.py para funcionar corretamente
- Preparado para instalação via Homebrew

### Changes
- Estrutura do pacote renomeada de `src/` para `rsctl/`
- Configuração do setup.py corrigida
- Versão atualizada para 0.0.2
```

5. Clique em **Publish release**

### 4. Atualizar Homebrew Formula

Depois que o release for criado, atualize a fórmula:

```bash
cd /Users/kelvin/www/pocs/cli/rserver/homebrew-rserver

# Calcular SHA256
VERSION="0.0.2"
URL="https://github.com/KelvinSilvaDev/rserver/archive/v${VERSION}.tar.gz"
SHA=$(curl -sL "$URL" | shasum -a 256 | cut -d' ' -f1)
echo "SHA256: $SHA"

# Atualizar formula
sed -i '' "s|url \".*\"|url \"https://github.com/KelvinSilvaDev/rserver/archive/v${VERSION}.tar.gz\"|" Formula/rserver.rb
sed -i '' "s|sha256 \".*\"|sha256 \"${SHA}\"|" Formula/rserver.rb

# Remover as correções do setup.py (não são mais necessárias)
# A fórmula agora pode ser simples:
cat > Formula/rserver.rb << 'EOF'
# Homebrew Formula para RSERVER
# Para usar: brew tap KelvinSilvaDev/rserver && brew install rserver

class Rserver < Formula
  desc "Remote Server Control - CLI multiplataforma para gerenciar serviços remotos"
  homepage "https://github.com/KelvinSilvaDev/rserver"
  url "https://github.com/KelvinSilvaDev/rserver/archive/v0.0.2.tar.gz"
  sha256 "COLE_O_SHA256_AQUI"
  license "Apache-2.0"
  head "https://github.com/KelvinSilvaDev/rserver.git", branch: "main"

  depends_on "python@3.9"

  def install
    cd "cli" do
      system "python3", "-m", "pip", "install", "--prefix=#{prefix}", "."
    end
  end

  test do
    system "#{bin}/rserver", "--version"
  end
end
EOF

# Substituir o SHA256
sed -i '' "s|sha256 \".*\"|sha256 \"${SHA}\"|" Formula/rserver.rb

# Commit e push
git add Formula/rserver.rb
git commit -m "Update rserver to v0.0.2"
git push
```

### 5. Testar instalação

```bash
# Atualizar tap
brew untap KelvinSilvaDev/rserver
brew tap KelvinSilvaDev/rserver

# Instalar
brew install rserver

# Verificar
rserver --version
# Deve mostrar: rserver 0.0.2
```

## 🎉 Pronto!

Agora o RSERVER está pronto para ser instalado via Homebrew!
