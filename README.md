# sdd-task-analyzer

[![CI](https://github.com/marquezzin/sdd-task-analyzer/actions/workflows/ci.yml/badge.svg)](https://github.com/marquezzin/sdd-task-analyzer/actions/workflows/ci.yml)

Módulo de análise de tarefas e produtividade, desenvolvido com **Spec-Driven Development (SDD)**
e geração de código assistida por IA. Projeto cumulativo da disciplina Bootcamp III (CEUB EAD).

- **Autor:** Gabriel Marques da Rocha
- **Contrato de negócio:** [`specs/task_analyzer_spec.md`](specs/task_analyzer_spec.md)
- **Governança de IA:** [`CONTEXT_RULES.md`](CONTEXT_RULES.md)

## Estrutura

```
sdd-task-analyzer/
├── .github/workflows/ci.yml
├── README.md
├── CONTEXT_RULES.md
├── .gitignore
├── requirements.txt
├── specs/task_analyzer_spec.md
├── tests/test_harness.py
└── src/task_analyzer.py
```

## Como executar

Requer Python 3.11+.

```bash
python -m venv venv
source venv/bin/activate        # Windows: venv\Scripts\activate
pip install -r requirements.txt
python -m pytest tests/ -v
```

## Integração contínua (CI/CD)

O pipeline em [`.github/workflows/ci.yml`](.github/workflows/ci.yml) roda a cada push ou pull request
nas branches `main` e `develop`:

1. ambiente `ubuntu-latest` com Python 3.11 (versão mínima do `CONTEXT_RULES.md`);
2. instalação das dependências autorizadas via `requirements.txt`;
3. execução de `pytest tests/test_harness.py -v`. Qualquer teste falhando derruba o build.

## Uso

```python
from datetime import datetime, timedelta, timezone
from src.task_analyzer import analisar_tarefas

inicio = datetime(2026, 10, 1, 9, 0, tzinfo=timezone.utc)
tarefas = [{
    "id_tarefa": 1, "titulo": "Exemplo", "prioridade": "alta", "status": "concluida",
    "data_criacao": inicio, "data_inicio": inicio,
    "data_conclusao": inicio + timedelta(minutes=60), "prazo": inicio + timedelta(hours=2),
}]
print(analisar_tarefas(tarefas))
```

## Status do build

O badge no topo reflete a última execução do pipeline na branch `main`. Histórico completo na aba
[Actions](https://github.com/marquezzin/sdd-task-analyzer/actions).
