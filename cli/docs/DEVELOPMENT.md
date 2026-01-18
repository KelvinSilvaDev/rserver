# 🛠️ Guia de Desenvolvimento

## Setup Inicial

### 1. Clonar Repositório

```bash
git clone <repo>
cd remote-server
```

### 2. Configurar Ambiente

```bash
# Instalar dependências de desenvolvimento
make dev-setup

# Ou manualmente
pip install -r cli/requirements-dev.txt
```

### 3. Validar Configuração

```bash
make validate-config
```

## Estrutura de Desenvolvimento

### Workflow

1. **Criar branch**: `git checkout -b feature/nova-funcionalidade`
2. **Desenvolver**: Escrever código e testes
3. **Testar**: `make test`
4. **Lint**: `make lint`
5. **Formatar**: `make format`
6. **Commit**: Commits descritivos
7. **Push**: `git push origin feature/nova-funcionalidade`

### Comandos Úteis

```bash
# Rodar testes
make test

# Verificar código
make lint

# Verificar tipos
make type-check

# Formatar código
make format

# Rodar tudo
make all

# Limpar arquivos temporários
make clean
```

## Escrevendo Testes

### Estrutura

```python
# tests/unit/test_manager.py
import pytest
from src.core.manager import ServiceManager

class TestServiceManager:
    @pytest.fixture
    def manager(self):
        return ServiceManager()
    
    def test_start_service_success(self, manager, mock_subprocess_run):
        # Teste aqui
        pass
```

### Rodar Testes

```bash
# Todos os testes
make test

# Apenas unitários
make test-unit

# Com cobertura
make test-coverage
```

## Padrões de Código

### Type Hints

Sempre usar type hints:

```python
def start_service(self, service_name: str, timeout: int = 30) -> bool:
    """Inicia serviço"""
    pass
```

### Docstrings

Usar Google style:

```python
def start_service(self, service_name: str, timeout: int = 30) -> bool:
    """Inicia um serviço específico.
    
    Args:
        service_name: Nome do serviço
        timeout: Timeout em segundos
        
    Returns:
        True se iniciado com sucesso
        
    Raises:
        ServiceStartError: Se falhar ao iniciar
    """
    pass
```

### Logging

Usar logger em vez de print:

```python
from src.utils import get_logger

logger = get_logger(__name__)

logger.info("Iniciando serviço")
logger.error("Erro ao iniciar", exc_info=True)
```

## Adicionar Novo Serviço

1. **Adicionar em `services.json`**:

```json
{
  "services": {
    "novo_servico": {
      "display_name": "Novo Serviço",
      "description": "Descrição",
      "port": 8080,
      "check_type": "http",
      "check_url": "http://localhost:8080",
      "start_cmd": ["systemctl", "start", "novo-servico"],
      "stop_cmd": ["systemctl", "stop", "novo-servico"]
    }
  }
}
```

2. **Adicionar em `start_order`** se necessário
3. **Validar**: `make validate-config`
4. **Testar**: `rserver start novo_servico`

## Debugging

### Modo Verboso

```bash
rserver --verbose start ssh
```

### Logs

```bash
tail -f logs/rserver.log
```

### Python Debugger

```python
import pdb; pdb.set_trace()
```

## Code Review Checklist

- [ ] Código segue padrões do projeto
- [ ] Type hints completos
- [ ] Docstrings em funções públicas
- [ ] Testes adicionados/atualizados
- [ ] Testes passando
- [ ] Lint passando
- [ ] Sem warnings de mypy
- [ ] Logging apropriado
- [ ] Tratamento de erros
- [ ] Documentação atualizada

## Troubleshooting

### Import Errors

```bash
# Verificar path
python -c "import sys; print(sys.path)"

# Adicionar src ao path
export PYTHONPATH="${PYTHONPATH}:$(pwd)/cli/src"
```

### Test Failures

```bash
# Rodar com mais verbosidade
pytest -vv tests/

# Rodar teste específico
pytest tests/unit/test_cache.py::TestCacheManager::test_get_set
```

### Type Check Errors

```bash
# Ver detalhes
mypy src/ --show-error-codes

# Ignorar imports faltando (temporário)
mypy src/ --ignore-missing-imports
```
