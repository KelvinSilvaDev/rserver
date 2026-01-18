# Makefile para desenvolvimento do RSERVER

.PHONY: help install test lint format clean dev-setup

# Variáveis
PYTHON := python3
PIP := pip3
CLI_DIR := cli
SRC_DIR := $(CLI_DIR)/src
TEST_DIR := $(CLI_DIR)/tests

help: ## Mostra esta mensagem de ajuda
	@echo "Comandos disponíveis:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

install: ## Instala a CLI globalmente
	@echo "📦 Instalando CLI..."
	@sudo ./$(CLI_DIR)/install.sh

test: ## Roda testes
	@echo "🧪 Rodando testes..."
	@cd $(CLI_DIR) && $(PYTHON) -m pytest tests/ -v

test-unit: ## Roda apenas testes unitários
	@echo "🧪 Rodando testes unitários..."
	@cd $(CLI_DIR) && $(PYTHON) -m pytest tests/unit/ -v

test-integration: ## Roda apenas testes de integração
	@echo "🧪 Rodando testes de integração..."
	@cd $(CLI_DIR) && $(PYTHON) -m pytest tests/integration/ -v

test-coverage: ## Roda testes com cobertura
	@echo "📊 Rodando testes com cobertura..."
	@cd $(CLI_DIR) && $(PYTHON) -m pytest tests/ --cov=src --cov-report=html --cov-report=term

lint: ## Verifica código com flake8
	@echo "🔍 Verificando código..."
	@cd $(CLI_DIR) && flake8 src/ tests/ --max-line-length=100 --exclude=__pycache__

type-check: ## Verifica tipos com mypy
	@echo "🔍 Verificando tipos..."
	@cd $(CLI_DIR) && mypy src/ --ignore-missing-imports

format: ## Formata código com black
	@echo "✨ Formatando código..."
	@cd $(CLI_DIR) && black src/ tests/

format-check: ## Verifica formatação sem modificar
	@echo "🔍 Verificando formatação..."
	@cd $(CLI_DIR) && black --check src/ tests/

validate-config: ## Valida arquivo de configuração
	@echo "✅ Validando configuração..."
	@cd $(CLI_DIR) && $(PYTHON) rsctl_new.py validate

dev-setup: ## Configura ambiente de desenvolvimento
	@echo "🛠️  Configurando ambiente de desenvolvimento..."
	@$(PIP) install --upgrade pip
	@$(PIP) install -r $(CLI_DIR)/requirements-dev.txt
	@echo "✅ Ambiente configurado!"

clean: ## Limpa arquivos temporários
	@echo "🧹 Limpando arquivos temporários..."
	@find . -type d -name "__pycache__" -exec rm -r {} + 2>/dev/null || true
	@find . -type f -name "*.pyc" -delete
	@find . -type d -name "*.egg-info" -exec rm -r {} + 2>/dev/null || true
	@find . -type d -name ".pytest_cache" -exec rm -r {} + 2>/dev/null || true
	@find . -type d -name ".mypy_cache" -exec rm -r {} + 2>/dev/null || true
	@find . -type d -name "htmlcov" -exec rm -r {} + 2>/dev/null || true
	@echo "✅ Limpeza concluída!"

run: ## Roda CLI (exemplo: make run ARGS="list")
	@cd $(CLI_DIR) && $(PYTHON) rsctl_new.py $(ARGS)

all: lint type-check format-check test ## Roda todas as verificações
