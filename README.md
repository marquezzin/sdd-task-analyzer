# sdd-task-analyzer

[![CI](https://github.com/marquezzin/sdd-task-analyzer/actions/workflows/ci.yml/badge.svg)](https://github.com/marquezzin/sdd-task-analyzer/actions/workflows/ci.yml)

Módulo de análise de tarefas e produtividade, desenvolvido com **Spec-Driven Development (SDD)**
e geração de código assistida por IA. Projeto cumulativo da disciplina Bootcamp III (CEUB EAD).

- **Autor:** Gabriel Marques da Rocha
- **Contrato de negócio:** [`specs/task_analyzer_spec.md`](specs/task_analyzer_spec.md)
- **Governança de IA:** [`CONTEXT_RULES.md`](CONTEXT_RULES.md)
- **Relatório de Governança e Ética (Fase 3):** [`docs/relatorio-governanca-etica.md`](docs/relatorio-governanca-etica.md)
- **Registro de prompts e homologação:** [`docs/prompts-log.md`](docs/prompts-log.md)

## Estrutura

```
sdd-task-analyzer/
├── .github/workflows/ci.yml        # pipeline de integração contínua (GitHub Actions)
├── Dockerfile                      # imagem python:3.11-slim com pytest como comando de entrada
├── docker-compose.yml              # serviço `tests`: a suíte inteira com um único comando
├── CONTEXT_RULES.md                # regras de governança de IA (Fase 1)
├── README.md
├── .gitignore
├── requirements.txt                # dependências autorizadas (só pytest)
├── specs/
│   ├── system_design_document.pdf  # especificação SDD da Fase 1 (contrato executável)
│   ├── task_analyzer_spec.md       # a mesma especificação, em Markdown
│   └── requirements.yaml           # contrato em formato legível por máquina
├── tests/test_harness.py           # suíte pytest: Cenários 1 e 2 e casos de borda
├── src/task_analyzer.py            # código gerado via IA e homologado por humano
└── docs/
    ├── relatorio-governanca-etica.md   # Pilar 3: alucinações, homologação, ética
    ├── prompts-log.md                  # rastreabilidade dos prompts (Fases 2 e 3)
    └── evidencias/                     # prints de CI e container
```

## Como executar

Requer Python 3.11+.

```bash
python -m venv venv
source venv/bin/activate        # Windows: venv\Scripts\activate
pip install -r requirements.txt
python -m pytest tests/test_harness.py -v
```

## Integração contínua (CI/CD)

O pipeline em [`.github/workflows/ci.yml`](.github/workflows/ci.yml) roda a cada push ou pull request
nas branches `main` e `develop`:

1. ambiente `ubuntu-latest` com Python 3.11 (versão mínima do `CONTEXT_RULES.md`);
2. instalação das dependências autorizadas via `requirements.txt`;
3. execução de `pytest tests/test_harness.py -v`. Qualquer teste falhando derruba o build.

## Execução em container (Docker)

A imagem parte de `python:3.11-slim`, copia o módulo e o harness e define o `pytest` como comando de
entrada. O `docker-compose.yml` define o serviço `tests`, então a suíte inteira roda com um único comando:

```bash
docker compose run --rm tests
```

Equivalente sem Compose:

```bash
docker build -t sdd-task-analyzer .
docker run --rm sdd-task-analyzer
```

O pipeline de CI também constrói a imagem e executa a suíte dentro dela (job `docker`).

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

## Governança de IA

O código de `src/` foi gerado por assistente de IA sob o contrato de `specs/` e as regras de
`CONTEXT_RULES.md`, e homologado por revisão humana antes de cada merge (Critical-in-the-Loop).
O que o contrato barrou, como a homologação foi feita e a rastreabilidade dos prompts estão em
[`docs/relatorio-governanca-etica.md`](docs/relatorio-governanca-etica.md) e
[`docs/prompts-log.md`](docs/prompts-log.md).

## Histórico das fases

| Fase | Entrega | Referência |
|---|---|---|
| 1 | Especificação SDD, cenários de aceite e CONTEXT_RULES | `specs/system_design_document.pdf` |
| 2 | Código via IA, test harness e PRs | publicado originalmente em [giovanniacg/sdd-task-analyzer](https://github.com/giovanniacg/sdd-task-analyzer) (PRs #1 e #2); histórico migrado para este repositório |
| 3 | CI/CD, Docker, relatório de governança e pitch técnico | PRs #1 a #3 deste repositório |

## Status do build

O badge no topo reflete a última execução do pipeline na branch `main`. Histórico completo na aba
[Actions](https://github.com/marquezzin/sdd-task-analyzer/actions).
