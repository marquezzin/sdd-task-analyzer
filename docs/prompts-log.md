# Registro de prompts e homologação (rastreabilidade de IA)

Cada entrega gerada com apoio de IA está resumida abaixo por pedido (texto parafraseado, não transcrição
literal), com data, contexto fornecido, resultado e veredito da revisão humana. Contexto padrão em todas:
`CONTEXT_RULES.md` + `specs/task_analyzer_spec.md`, fornecidos antes do pedido (CONTEXT_RULES 3.1).

## Fase 2 (implementação com IA e test harness)

Ferramenta: Claude (Anthropic), via assistente de código. Modelo nos commits: Claude Sonnet 5.5.
Repositório da fase: https://github.com/giovanniacg/sdd-task-analyzer

| # | Data | Pedido | Resultado | Homologação |
|---|---|---|---|---|
| 2.1 | 2026-10-16 | Reformular o contrato (entradas, saídas, regras 1 a 9, exceções) antes de gerar qualquer linha de código (CONTEXT_RULES 3.2). | Reformulação aceita; três pontos marcados como não especificados ou ambíguos: prioridade sem concluídas e valores fora do contrato (a spec não cobre) e lista vazia (coberta pela regra 5, mas em conflito com o enunciado da Fase 2). | Aprovado. Os três pontos viraram decisões documentadas no [PR #2](https://github.com/giovanniacg/sdd-task-analyzer/pull/2). |
| 2.2 | 2026-10-16 | Escrever `tests/test_harness.py` a partir dos Cenários 1 e 2 e dos casos de borda, antes da implementação. | 14 funções de teste (19 casos com parametrização) e fixtures; `pytest` falhou com `ModuleNotFoundError` até o módulo existir. | Aprovado ([PR #1](https://github.com/giovanniacg/sdd-task-analyzer/pull/1)). |
| 2.3 | 2026-10-16 | Implementar `src/task_analyzer.py` com a assinatura exata `analisar_tarefas(tarefas: list[dict]) -> dict`, `TarefaInvalidaError`, `MetricasIndisponiveisError`, só biblioteca padrão, type hints, docstrings Google, `logging`. | Módulo com 8 funções pequenas; 19 testes aprovados; exemplo de referência da spec reproduzido. | Aprovado com checklist das CONTEXT_RULES ([PR #2](https://github.com/giovanniacg/sdd-task-analyzer/pull/2)). Rejeitados: nomes do enunciado (`analyze_tasks`, `TaskValidationError`, horas) e "retornar 0.0" para lista vazia. |

## Fase 3 (CI/CD, Docker, governança)

Ferramenta: Claude Code (Anthropic), modelo Claude Fable 5.1. Contexto adicional: o enunciado da Fase 3
(slides) e o relatório da Fase 2. Repositório da fase: https://github.com/marquezzin/sdd-task-analyzer

| # | Data | Pedido | Resultado | Homologação |
|---|---|---|---|---|
| 3.1 | 2026-10-24 | Ler o repositório e o enunciado da Fase 3; propor o pipeline do Pilar 1 (gatilhos em `main` e `develop`, `ubuntu-latest`, Python 3.11, `requirements.txt`, `pytest tests/test_harness.py -v`). | `.github/workflows/ci.yml` com job `test`; badge no README. | Aprovado. Conferido: nenhuma dependência além do `requirements.txt`; `permissions: contents: read`; versão 3.11 fixada (e não a 3.14 da máquina local). |
| 3.2 | 2026-10-24 | Containerizar a suíte conforme o Pilar 2: `python:3.11-slim`, pytest como `CMD`, `docker-compose.yml` com serviço único. | `Dockerfile`, `docker-compose.yml`, `.dockerignore`, job `docker` no CI. | Aprovado. Conferido na revisão: só `requirements.txt`, `src/` e `tests/` copiados (não `COPY . .`), usuário sem privilégios. Validado localmente: 19 aprovados em Python 3.11.17 no container. |
| 3.3 | 2026-10-24 | Transcrever a spec para `specs/requirements.yaml` (formato legível por máquina), separando o que vem da spec do que veio de decisão da Fase 2 ou da implementação. | Arquivo com entradas, saídas, regras 1 a 9, exceções, cenários e mapeamento de testes. | Aprovado após ajuste de revisão: a primeira versão listava como contrato gatilhos de `TarefaInvalidaError` que são decisão da Fase 2 (campo ausente, valores fora do contrato, id inválido) e trazia `base: ValueError`, que é implementação. Ficaram em chaves próprias. O Markdown continua sendo a fonte da verdade em caso de conflito. |
| 3.4 | 2026-10-24 | Redigir o relatório técnico de governança e ética (Pilar 3) a partir dos fatos dos PRs, do código e das execuções. | `docs/relatorio-governanca-etica.md`. | Conferência contra o código corrigiu "10 funções" para 8 antes da revisão. Revisado pelo autor. |
| 3.5 | 2026-10-24 | Atualizar o README (badge, seções de CI e Docker, árvore final, histórico das fases) e redigir este registro de prompts. | README e `docs/prompts-log.md`. | Revisado pelo autor. Comando local do README alinhado ao do CI e do container (`pytest tests/test_harness.py -v`). |
| 3.6 | 2026-10-24 | Revisão adversarial do relatório e deste registro por um segundo agente de IA (revisor), antes da leitura do autor: caçar afirmação sem lastro no código, regra citada errada, fato inflado, inconsistência entre documentos. | 12 correções obrigatórias e 14 melhorias apontadas. | Aplicadas: regra errada no item 4 da tabela (3.3 trocada pela regra 9 da spec), narrativa dos itens de infraestrutura (não houve correção humana de saída da IA), ordem das etapas do fluxo alinhada à CONTEXT_RULES 3.4, separação spec x decisão no YAML, limites conhecidos ampliados. O aceite final é do autor. |

## Regras de uso que valeram nas duas fases

- A IA nunca recebeu o pedido sem o contrato completo antes.
- Toda saída foi lida antes de rodar o harness (CONTEXT_RULES 3.4).
- Desvio do contrato foi devolvido com a regra violada, não aceito (CONTEXT_RULES 3.5).
- Nenhum teste fornecido foi alterado ou removido (CONTEXT_RULES 2.2).
- Commits gerados com apoio de IA declaram o modelo na linha `Co-Authored-By`.
