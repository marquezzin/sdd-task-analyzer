# Relatório Técnico de Governança e Ética de IA

- **Projeto:** TaskAnalyzer (sdd-task-analyzer)
- **Disciplina:** Bootcamp III, CEUB EAD. Desafio Final (Fase 3, 25,0 pontos)
- **Autor:** Gabriel Marques da Rocha, Ciência da Computação, Turma A - 0726
- **Repositório:** https://github.com/marquezzin/sdd-task-analyzer
- **Vídeo (pitch técnico):** a publicar (link na entrega do AVA)

## 1. Contexto e escopo desta fase

O TaskAnalyzer é um módulo Python de métricas de produtividade (tempo médio de conclusão e taxa de atraso, gerais e por prioridade). O projeto é cumulativo:

| Fase | Entrega | Onde está |
|---|---|---|
| 1 | Especificação SDD (contrato executável), cenários de aceite e CONTEXT_RULES | `specs/system_design_document.pdf`, `specs/task_analyzer_spec.md`, `CONTEXT_RULES.md` |
| 2 | Código gerado por IA, test harness (19 testes) e versionamento com PRs | `src/task_analyzer.py`, `tests/test_harness.py`; publicado originalmente em `giovanniacg/sdd-task-analyzer` (PRs #1 e #2) |
| 3 | CI/CD, containerização, este relatório e o pitch técnico | `.github/workflows/ci.yml`, `Dockerfile`, `docker-compose.yml`, `docs/`, `specs/requirements.yaml` |

Para a Fase 3 o histórico completo de commits da Fase 2 foi migrado para a conta do autor (`marquezzin/sdd-task-analyzer`), preservando autoria, mensagens e a estrutura de branches. O trabalho desta fase entrou por três branches de funcionalidade e três pull requests, cada um com checklist de homologação:

| PR | Branch | Conteúdo |
|---|---|---|
| #1 | `feature/ci-cd` | pipeline GitHub Actions e badge no README |
| #2 | `feature/docker` | Dockerfile, docker-compose.yml, job `docker` no CI |
| #3 | `feature/governance-docs` | SDD em PDF, `requirements.yaml`, este relatório, registro de prompts |

Assistente de IA usado nesta fase: Claude Code (Anthropic). Na Fase 2: Claude, via assistente de código. Em ambas, o contexto fornecido antes de qualquer geração foi `CONTEXT_RULES.md` + `specs/task_analyzer_spec.md`, e cada saída passou por revisão humana antes de entrar no repositório.

## 2. Pilar 1: integração contínua (GitHub Actions)

Arquivo: `.github/workflows/ci.yml`.

- **Gatilhos:** `push` e `pull_request` nas branches `main` e `develop`.
- **Ambiente:** `ubuntu-latest` com Python **3.11**, que é a versão mínima exigida pelo CONTEXT_RULES 1.1. A máquina de desenvolvimento roda Python 3.14; o pipeline fixa 3.11 de propósito, para provar que o código atende ao mínimo do contrato e não apenas ao ambiente de quem escreveu.
- **Preparação:** `pip install -r requirements.txt`. O arquivo contém apenas `pytest`; nenhuma dependência extra foi adicionada ao pipeline (CONTEXT_RULES 2.1).
- **Execução:** `pytest tests/test_harness.py -v`. Qualquer teste falhando derruba o build e bloqueia o merge do PR.
- **Segundo job (`docker`):** depende do primeiro, constrói a imagem com `docker compose build` e executa a suíte dentro do container com `docker compose run --rm tests`. O pipeline valida, portanto, o código e o empacotamento.
- **Permissões:** o workflow declara `permissions: contents: read`, o mínimo necessário para fazer checkout.

Evidência: execução verde na branch `main`, com os dois jobs aprovados.

![Execução do pipeline na branch main, jobs test e docker aprovados](evidencias/ci-main-verde.png)

## 3. Pilar 2: containerização (Docker e Docker Compose)

**Dockerfile** (empacotamento):

- base `python:3.11-slim`, leve e imutável, na mesma versão mínima do contrato;
- `requirements.txt` copiado e instalado antes do código, para aproveitar o cache de camadas;
- só `src/` e `tests/` entram na imagem (o `.dockerignore` exclui `.git`, documentação, caches e ambientes virtuais);
- a suíte roda como usuário sem privilégios (`analyzer`), não como root;
- `CMD ["pytest", "tests/test_harness.py", "-v"]` como comando de entrada.

**docker-compose.yml** (orquestração): define o serviço `tests`, apontando para o Dockerfile, com a mesma linha de comando. A suíte inteira roda com um único comando, em qualquer máquina com Docker:

```bash
docker compose run --rm tests
```

Evidência: execução local na imagem construída (Python 3.11.17 dentro do container, 231 MB de imagem):

```text
============================= test session starts ==============================
platform linux -- Python 3.11.17, pytest-9.1.1, pluggy-1.7.0 -- /usr/local/bin/python3.11
cachedir: .pytest_cache
rootdir: /app
collecting ... collected 19 items

tests/test_harness.py::test_metricas_gerais_com_tarefas_validas PASSED   [  5%]
tests/test_harness.py::test_indicadores_por_prioridade PASSED            [ 10%]
tests/test_harness.py::test_ignora_tarefas_nao_concluidas PASSED         [ 15%]
tests/test_harness.py::test_arredonda_com_duas_casas_decimais PASSED     [ 21%]
tests/test_harness.py::test_prioridade_sem_tarefas_concluidas_retorna_zeros PASSED [ 26%]
tests/test_harness.py::test_nao_altera_a_lista_de_entrada PASSED         [ 31%]
tests/test_harness.py::test_excecao_data_conclusao_antes_do_inicio PASSED [ 36%]
tests/test_harness.py::test_excecao_concluida_sem_datas_de_execucao PASSED [ 42%]
tests/test_harness.py::test_excecao_sem_tarefas_concluidas PASSED        [ 47%]
tests/test_harness.py::test_excecao_lista_vazia PASSED                   [ 52%]
tests/test_harness.py::test_excecao_valor_fora_do_contrato[prioridade-urgente] PASSED [ 57%]
tests/test_harness.py::test_excecao_valor_fora_do_contrato[status-arquivada] PASSED [ 63%]
tests/test_harness.py::test_excecao_valor_fora_do_contrato[titulo-  ] PASSED [ 68%]
tests/test_harness.py::test_excecao_campo_obrigatorio_ausente PASSED     [ 73%]
tests/test_harness.py::test_excecao_id_repetido PASSED                   [ 78%]
tests/test_harness.py::test_excecao_id_invalido[0] PASSED                [ 84%]
tests/test_harness.py::test_excecao_id_invalido[-1] PASSED               [ 89%]
tests/test_harness.py::test_excecao_id_invalido[1] PASSED                [ 94%]
tests/test_harness.py::test_excecao_id_invalido[True] PASSED             [100%]

============================== 19 passed in 0.01s ==============================
```

O mesmo resultado da execução local da Fase 2 (19 aprovados), agora reproduzido em ambiente isolado. É isso que elimina o "na minha máquina funciona": o ambiente de teste passa a ser um artefato versionado, não uma configuração pessoal.

## 4. Pilar 3: governança e ética de IA

### 4.1 Análise de alucinações: o que o contrato barrou

"Alucinação", aqui, é qualquer saída da IA que inventa comportamento, dependência ou nome fora do contrato de negócio. O SDD e o CONTEXT_RULES funcionaram como firewall nos pontos abaixo, todos verificáveis no código e nos PRs.

| # | Ponto de desvio | Regra que barrou | O que ficou no código |
|---|---|---|---|
| 1 | Importar `pandas`, `python-dateutil` ou similares para manipular datas e agregações | CONTEXT_RULES 2.1 (só biblioteca padrão; `pytest` apenas no harness) | `src/task_analyzer.py` importa somente `logging`, `datetime` e `typing`. `requirements.txt` contém só `pytest`. |
| 2 | Adotar os nomes genéricos do enunciado (`analyze_tasks`, `TaskValidationError`, tempos em horas) | Spec 1.3.1 (assinatura pública não pode ser alterada) e CONTEXT_RULES 2.5 | `analisar_tarefas(tarefas: list[dict]) -> dict`, `TarefaInvalidaError`, `tempo_medio_conclusao_min`. O enunciado da Fase 3 ainda cita `TaskValidationError`; a spec da Fase 1 continua sendo a fonte da verdade. |
| 3 | Lista vazia ou só tarefas pendentes "retornar 0.0", como sugere o enunciado da Fase 2 | Spec, regra 5 (denominador zero dispara `MetricasIndisponiveisError`) e CONTEXT_RULES 2.8 (não assumir comportamento não especificado) | `test_excecao_lista_vazia` e `test_excecao_sem_tarefas_concluidas` exigem a exceção. A divergência foi documentada no PR, não resolvida por palpite. |
| 4 | Prioridade sem nenhuma tarefa concluída: a spec não define o valor | CONTEXT_RULES 2.8 e 3.3 (dúvida vira pergunta, não suposição) | Decisão explícita e registrada no PR: o grupo retorna `0.0`, `0.0` e `0`. Coberta por `test_prioridade_sem_tarefas_concluidas_retorna_zeros`. |
| 5 | Validar `id_tarefa` com `isinstance(id, int)`, que aceita `True` como inteiro válido em Python | Spec 1.3.1 (inteiro > 0) traduzida no harness: `test_excecao_id_invalido[True]` | A implementação rejeita `bool` explicitamente antes de testar `int`. O harness pega esse caso antes de qualquer revisor. |
| 6 | Descartar em silêncio tarefa com data inconsistente e seguir calculando | Spec, regra 4 e nota de decisão (falhar explicitamente) | `TarefaInvalidaError` com o id da tarefa na mensagem; `test_excecao_data_conclusao_antes_do_inicio` exige o id. |
| 7 | No CI, instalar linters e ferramentas de cobertura fora do `requirements.txt`, como fazem os templates comuns de pipeline | CONTEXT_RULES 2.1 | O pipeline instala só o que está em `requirements.txt` e roda só o harness. |
| 8 | No Dockerfile, `COPY . .` e execução como root, padrão dos exemplos genéricos | Revisão humana com a lente de superfície mínima (ver 4.2) | Só `src/` e `tests/` entram na imagem; usuário `analyzer` sem privilégios. |

Dois mecanismos distintos aparecem na tabela. Os itens 1 a 6 são bloqueios do **contrato**: a regra existia antes do código e o harness ou a revisão a aplicou. Os itens 7 e 8 são bloqueios da **homologação humana** sobre infraestrutura, onde não havia teste automatizado e a decisão coube ao revisor.

### 4.2 Homologação humana (Critical-in-the-Loop)

O fluxo adotado nas Fases 2 e 3 segue quatro etapas, nessa ordem:

1. **Geração.** A IA recebe `CONTEXT_RULES.md` + spec e, antes de gerar código, reformula o que vai fazer (CONTEXT_RULES 3.2). Só depois produz o artefato.
2. **Barreira SDD.** O harness roda. Na Fase 2 ele foi escrito antes da implementação e falhou de propósito (`ModuleNotFoundError`) até o código existir. Na Fase 3, a barreira ganhou duas camadas: o pipeline de CI em Python 3.11 e a suíte dentro do container.
3. **Validação humana.** O revisor confere o diff contra um checklist derivado das CONTEXT_RULES e registra o resultado no PR. O humano é filtro primário, não espectador.
4. **Integração segura.** Merge só via pull request, só com o CI verde.

Checklist aplicado ao código (PR da implementação, Fase 2):

- [x] Python 3.11+ e type hints em todas as funções
- [x] Apenas biblioteca padrão; sem persistência em arquivo ou banco
- [x] Assinatura pública `analisar_tarefas(tarefas: list[dict]) -> dict` inalterada
- [x] Exceções específicas com o id da tarefa na mensagem; nenhum `except Exception`
- [x] Docstrings Google style e `logging` (sem `print`)
- [x] Funções pequenas e coesas (SRP)

Checklist aplicado à infraestrutura (PRs da Fase 3):

- [x] Pipeline instala só o que está em `requirements.txt`
- [x] Versão de Python fixada em 3.11 no CI e na imagem (mínimo do contrato)
- [x] Comando do CI idêntico ao comando do container e ao comando documentado no README
- [x] Imagem base `slim`; só `src/` e `tests/` copiados; usuário sem privilégios
- [x] `permissions: contents: read` no workflow
- [x] Build e execução validados localmente antes do push (19 aprovados no container)
- [x] Nenhuma alteração em `src/`, `tests/`, `specs/task_analyzer_spec.md` ou `CONTEXT_RULES.md` (CONTEXT_RULES 2.2 e 2.3)

O que o revisor humano fez que a automação não faria: decidiu o tratamento dos casos não especificados (itens 3 e 4 da tabela), rejeitou os nomes do enunciado em favor da spec (item 2) e restringiu a superfície da imagem (item 8). Todas essas decisões estão escritas nos PRs, com a regra que as motivou.

### 4.3 Sustentabilidade, rastreabilidade e ética

**Rastreabilidade de prompts.** Os prompts das Fases 2 e 3, o contexto fornecido em cada um e o resultado da homologação estão em `docs/prompts-log.md`. Os commits gerados com apoio da IA levam a linha `Co-Authored-By` identificando o assistente; as descrições dos PRs seguem o formato "o que muda / evidência / homologação contra as CONTEXT_RULES / decisões em aberto".

**Conformidade do código final gerado por IA.** Verificação feita sobre `src/task_analyzer.py` na versão mergeada:

| Regra (CONTEXT_RULES) | Como foi verificado | Resultado |
|---|---|---|
| 1.1 Python 3.11+ | CI e imagem rodam em 3.11; sintaxe `list[dict]`, `float | int` exige 3.10+ | conforme |
| 1.2 Type hints em todas as funções | leitura das 8 funções do módulo | conforme (todas anotadas, incluindo retorno) |
| 1.4 Docstrings Google style | leitura | conforme (módulo, classes e funções) |
| 1.6 Exceções específicas, sem `except Exception` | busca textual | 0 ocorrências de `except Exception` |
| 1.7 `logging`, nunca `print` | busca textual | 0 ocorrências de `print(`; logger de módulo em uso |
| 2.1 Só biblioteca padrão | lista de imports | `logging`, `datetime`, `typing` |
| 2.4 Sem persistência | leitura | nenhum acesso a arquivo, rede ou banco |
| 2.5 Assinatura inalterada | comparação com a spec 1.3.1 | idêntica |
| Spec, regra 7 (2 casas decimais) | `test_arredonda_com_duas_casas_decimais` | aprovado |
| Spec, regra 8 (sem efeitos colaterais) | `test_nao_altera_a_lista_de_entrada` | aprovado |

**Ética e dados.** Os dados de teste são fictícios e gerados no próprio harness; não há dado pessoal, credencial ou segredo no repositório. O módulo não persiste nem transmite nada (regra 8). O uso de IA está declarado no README, nos commits e neste relatório: a IA gerou, o autor homologou e responde pelo resultado. Nenhuma saída da IA entrou no repositório sem passar pelo harness e pela revisão.

**Sustentabilidade computacional.** A imagem parte de `python:3.11-slim` (231 MB, contra mais de 1 GB da imagem completa), instala uma única dependência sem cache de pip e reaproveita camadas entre builds. O CI roda apenas em `main` e `develop` e usa cache de pip no runner. A suíte executa em menos de um segundo. São escolhas de custo computacional menor, não um selo ambiental: o ganho é proporcional ao tamanho pequeno do projeto.

**Limites conhecidos.** O harness cobre os cenários de aceite e os casos de borda do contrato, não todos os caminhos possíveis (não há medição de cobertura, por decisão de manter só a dependência autorizada). Os casos não especificados pela spec (itens 3 e 4 da tabela) foram decididos pelo autor e documentados; uma revisão da spec na origem seria o caminho correto para formalizá-los.

## 5. Conclusão

O código do TaskAnalyzer já passava em 19 testes na Fase 2. A Fase 3 tornou essa afirmação verificável por qualquer pessoa: o pipeline reproduz a suíte em Python 3.11 a cada push, a imagem Docker a reproduz em qualquer máquina com um comando, e este relatório registra onde a IA poderia ter desviado e por que não desviou. Confiabilidade técnica (Docker e CI) e confiabilidade ética (SDD e CONTEXT_RULES) estão no mesmo repositório, e uma depende da outra.
