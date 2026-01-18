# 🤝 Guia de Contribuição

Obrigado por considerar contribuir com o RSERVER! Este documento fornece diretrizes para contribuir de forma eficaz.

## 📋 Índice

- [Código de Conduta](#código-de-conduta)
- [Como Contribuir](#como-contribuir)
- [Configuração do Ambiente](#configuração-do-ambiente)
- [Padrões de Código](#padrões-de-código)
- [Processo de Pull Request](#processo-de-pull-request)
- [Testes](#testes)
- [Documentação](#documentação)

## 📜 Código de Conduta

Este projeto segue um Código de Conduta. Ao participar, você concorda em manter este código.

**Princípios:**
- Seja respeitoso e inclusivo
- Aceite críticas construtivas
- Foque no que é melhor para a comunidade
- Mostre empatia com outros membros

## 🚀 Como Contribuir

### Reportar Bugs

1. **Verifique se o bug já foi reportado** - Procure nas [Issues](https://github.com/KelvinSilvaDev/rserver/issues)
2. **Crie uma issue** se não existir:
   - Título claro e descritivo
   - Descrição do problema
   - Passos para reproduzir
   - Comportamento esperado vs. atual
   - Ambiente (OS, versão Python, etc.)
   - Logs relevantes (se houver)

### Sugerir Melhorias

1. **Verifique se já foi sugerido** - Procure nas Issues
2. **Crie uma issue** com:
   - Descrição clara da melhoria
   - Casos de uso
   - Benefícios
   - Possível implementação (se tiver ideias)

### Contribuir com Código

1. **Fork o repositório**
2. **Crie uma branch** para sua feature/fix:
   ```bash
   git checkout -b feature/minha-feature
   # ou
   git checkout -b fix/corrigir-bug
   ```
3. **Faça suas alterações**
4. **Adicione testes** (se aplicável)
5. **Atualize documentação** (se necessário)
6. **Commit suas mudanças**:
   ```bash
   git commit -m "feat: adiciona nova funcionalidade X"
   ```
7. **Push para sua branch**:
   ```bash
   git push origin feature/minha-feature
   ```
8. **Abra um Pull Request**

## 🛠️ Configuração do Ambiente

### Pré-requisitos

- Python 3.7+
- Git
- (Opcional) Virtual environment

### Setup Inicial

```bash
# 1. Fork e clone o repositório
git clone https://github.com/KelvinSilvaDev/rserver.git
cd rserver

# 2. Criar virtual environment (recomendado)
python3 -m venv venv

# 3. Ativar virtual environment
# Linux/macOS:
source venv/bin/activate
# Windows:
venv\Scripts\activate

# 4. Instalar dependências de desenvolvimento
pip install -r cli/requirements-dev.txt

# 5. Instalar CLI em modo desenvolvimento
pip install -e .

# 6. Verificar instalação
rserver --help
```

### Estrutura do Projeto

```
rserver/
├── cli/
│   ├── src/              # Código fonte
│   │   ├── core/         # Funcionalidade core
│   │   ├── cli/          # Interface CLI
│   │   └── utils/        # Utilitários
│   ├── tests/            # Testes
│   ├── docs/             # Documentação técnica
│   └── scripts/          # Scripts auxiliares
├── docs/                 # Documentação do projeto
└── README.md             # Documentação principal
```

## 📝 Padrões de Código

### Python

- **Type Hints**: Sempre usar type hints
- **Docstrings**: Google style para funções/classes públicas
- **Formatação**: Black (linha 100 caracteres)
- **Linting**: Flake8
- **Type Checking**: mypy

### Convenções de Commit

Seguimos [Conventional Commits](https://www.conventionalcommits.org/):

```
feat: adiciona nova funcionalidade
fix: corrige bug
docs: atualiza documentação
style: formatação (não afeta código)
refactor: refatoração
test: adiciona testes
chore: tarefas de manutenção
```

**Exemplos:**
```bash
git commit -m "feat: adiciona suporte para macOS"
git commit -m "fix: corrige detecção de plataforma no Windows"
git commit -m "docs: atualiza guia de instalação"
```

### Nomenclatura

- **Funções/Métodos**: `snake_case`
- **Classes**: `PascalCase`
- **Constantes**: `UPPER_SNAKE_CASE`
- **Arquivos**: `snake_case.py`

### Exemplo de Código

```python
from typing import Optional, List
import logging

logger = logging.getLogger(__name__)


class ServiceManager:
    """
    Gerencia serviços do servidor remoto.
    
    Attributes:
        config: Configuração carregada dos serviços
    """
    
    def start_service(
        self,
        service_name: str,
        timeout: int = 30
    ) -> bool:
        """
        Inicia um serviço específico.
        
        Args:
            service_name: Nome do serviço a iniciar
            timeout: Timeout em segundos
            
        Returns:
            True se o serviço foi iniciado com sucesso
            
        Raises:
            ServiceStartError: Se falhar ao iniciar
        """
        # Implementação
        pass
```

## 🔄 Processo de Pull Request

### Antes de Abrir um PR

1. **Atualize sua branch**:
   ```bash
   git fetch upstream
   git rebase upstream/main
   ```

2. **Execute testes**:
   ```bash
   make test
   # ou
   pytest
   ```

3. **Verifique código**:
   ```bash
   make lint
   make type-check
   make format-check
   ```

4. **Atualize documentação** (se necessário)

### Criando o PR

1. **Título claro e descritivo**
2. **Descrição detalhada**:
   - O que foi alterado
   - Por que foi alterado
   - Como testar
   - Screenshots (se UI)
3. **Referencie issues** relacionadas: `Fixes #123`
4. **Mantenha PRs pequenos** - Um PR por feature/fix

### Revisão

- Mantenha-se aberto a feedback
- Responda a comentários
- Faça alterações solicitadas
- Mantenha o PR atualizado

## 🧪 Testes

### Executar Testes

```bash
# Todos os testes
make test

# Apenas unitários
make test-unit

# Com cobertura
make test-coverage

# Teste específico
pytest tests/unit/test_cache.py -v
```

### Escrever Testes

```python
import pytest
from src.core.manager import ServiceManager

class TestServiceManager:
    @pytest.fixture
    def manager(self):
        return ServiceManager()
    
    def test_start_service_success(self, manager):
        # Arrange
        service_name = "ssh"
        
        # Act
        result = manager.start_service(service_name)
        
        # Assert
        assert result is True
```

### Cobertura Mínima

- **Meta**: 80% de cobertura
- **Foco**: Lógica de negócio e tratamento de erros

## 📚 Documentação

### Atualizar Documentação

Se sua alteração afeta:
- **Funcionalidade**: Atualize `DOCUMENTACAO.md`
- **Instalação**: Atualize `PLATAFORMAS.md` e `cli/INSTALL-REMOTE.md`
- **Desenvolvimento**: Atualize `cli/docs/DEVELOPMENT.md`
- **Arquitetura**: Atualize `cli/docs/ARCHITECTURE.md`

### Padrões de Documentação

- Use Markdown
- Inclua exemplos de código
- Mantenha links atualizados
- Use emojis consistentemente (opcional)

## 🌐 Multiplataforma

### Testar em Múltiplas Plataformas

Se sua alteração afeta compatibilidade:

1. **Teste em Linux** (se possível)
2. **Teste em macOS** (se possível)
3. **Teste em Windows** (se possível)
4. **Documente limitações** (se houver)

### Comandos Específicos de Plataforma

Use `src/utils/platform.py` para detecção:

```python
from src.utils.platform import PlatformDetector

if PlatformDetector.is_windows():
    # Código Windows
elif PlatformDetector.is_macos():
    # Código macOS
else:
    # Código Linux
```

## 🐛 Reportar Problemas

### Template de Issue

```markdown
**Plataforma:**
- [ ] Linux
- [ ] macOS
- [ ] Windows

**Versão Python:**
- [ ] 3.7
- [ ] 3.8
- [ ] 3.9
- [ ] 3.10+
- [ ] Outra: _____

**Descrição:**
[Descreva o problema]

**Passos para Reproduzir:**
1. ...
2. ...
3. ...

**Comportamento Esperado:**
[O que deveria acontecer]

**Comportamento Atual:**
[O que está acontecendo]

**Logs:**
```
[Cole logs relevantes]
```
```

## ✅ Checklist Antes de Enviar

- [ ] Código segue padrões do projeto
- [ ] Testes adicionados/atualizados
- [ ] Testes passando
- [ ] Lint passando
- [ ] Type checking passando
- [ ] Documentação atualizada
- [ ] Commits seguem convenções
- [ ] PR tem descrição clara
- [ ] Testado em plataforma relevante (se aplicável)

## 📞 Dúvidas?

- Abra uma issue com tag `question`
- Consulte a [documentação](DOCUMENTACAO.md)
- Veja [issues existentes](https://github.com/KelvinSilvaDev/rserver/issues)

---

**Obrigado por contribuir! 🎉**
