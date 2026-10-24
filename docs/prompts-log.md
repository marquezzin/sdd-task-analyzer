# Registro de prompts e homologação (rastreabilidade de IA)

Cada interação com assistente de IA que gerou artefato deste repositório está listada abaixo com o
contexto fornecido, o pedido, o resultado e o veredito da revisão humana. Contexto padrão em todas:
`CONTEXT_RULES.md` + `specs/task_analyzer_spec.md`, fornecidos antes do pedido (CONTEXT_RULES 3.1).

## Fase 2 (implementação com IA e test harness)

Ferramenta: Claude (Anthropic), via assistente de código.

| # | Pedido | Resultado | Homologação |
|---|---|---|---|
| 2.1 | Reformular o contrato (entradas, saídas, regras 1 a 9, exceções) antes de gerar qualquer linha de código (CONTEXT_RULES 3.2). | Reformulação aceita; três pontos marcados como não especificados pela spec (prioridade sem concluídas, valores fora do contrato, lista vazia). | Aprovado. Os pontos em aberto viraram decisões documentadas no PR #2 do repositório original. |
| 2.2 | Escrever `tests/test_harness.py` a partir dos Cenários 1 e 2 e dos casos de borda, antes da implementação. | 19 casos com fixtures; `pytest` falhou com `ModuleNotFoundError` até o módulo existir. | Aprovado (PR #1 do repositório original). |
| 2.3 | Implementar `src/task_analyzer.py` com a assinatura exata `analisar_tarefas(tarefas: list[dict]) -> dict`, `TarefaInvalidaError`, `MetricasIndisponiveisError`, só biblioteca padrão, type hints, docstrings Google, `logging`. | Módulo com 8 funções pequenas; 19 testes aprovados; exemplo de referência da spec reproduzido. | Aprovado com checklist das CONTEXT_RULES (PR #2 do repositório original). Rejeitados: nomes do enunciado (`analyze_tasks`, `TaskValidationError`, horas) e "retornar 0.0" para lista vazia. |

## Fase 3 (CI/CD, Docker, governança)

Ferramenta: Claude Code (Anthropic). Contexto adicional: o enunciado da Fase 3 (slides) e o relatório da Fase 2.

| # | Pedido | Resultado | Homologação |
|---|---|---|---|
| 3.1 | Ler o repositório e o enunciado da Fase 3; propor o pipeline do Pilar 1 (gatilhos em `main` e `develop`, `ubuntu-latest`, Python 3.11, `requirements.txt`, `pytest tests/test_harness.py -v`). | `.github/workflows/ci.yml` com job `test`; badge no README. | Aprovado. Conferido: nenhuma dependência além do `requirements.txt`; `permissions: contents: read`; versão 3.11 fixada (e não a 3.14 da máquina local). |
| 3.2 | Containerizar a suíte conforme o Pilar 2: `python:3.11-slim`, pytest como `CMD`, `docker-compose.yml` com serviço único. | `Dockerfile`, `docker-compose.yml`, `.dockerignore`, job `docker` no CI. | Aprovado após ajuste de revisão: só `src/` e `tests/` copiados (não `COPY . .`), usuário sem privilégios. Validado localmente: 19 aprovados em Python 3.11.17 no container. |
| 3.3 | Transcrever a spec para `specs/requirements.yaml` (formato legível por máquina) sem alterar nenhuma regra. | Arquivo com entradas, saídas, regras 1 a 9, exceções, cenários e mapeamento de testes. | Aprovado. Conferido campo a campo contra `task_analyzer_spec.md`; o Markdown continua sendo a fonte da verdade em caso de conflito. |
| 3.4 | Redigir o relatório técnico de governança e ética (Pilar 3) a partir dos fatos dos PRs, do código e das execuções. | `docs/relatorio-governanca-etica.md`. | Revisado pelo autor; números e evidências conferidos contra as execuções reais (CI e container). |

## Regras de uso que valeram nas duas fases

- A IA nunca recebeu o pedido sem o contrato completo antes.
- Toda saída foi lida antes de rodar o harness (CONTEXT_RULES 3.4).
- Desvio do contrato foi devolvido com a regra violada, não aceito (CONTEXT_RULES 3.5).
- Nenhum teste fornecido foi alterado ou removido (CONTEXT_RULES 2.2).
- Commits gerados com apoio da IA declaram o assistente na linha `Co-Authored-By`.
