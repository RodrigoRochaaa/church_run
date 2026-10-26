# DOCS-GUIDE.md: para que serve cada arquivo .md

> Regra geral: **cada informação mora em um lugar só.** Os outros arquivos apontam para ela com um link. Se você se pegar copiando um parágrafo de um `.md` para outro, troque a cópia por um link.

## Mapa rápido

| Arquivo | Pergunta que responde | Quem atualiza | Quando | Como muda |
|---|---|---|---|---|
| `CLAUDE.md` | "Quais regras eu tenho que seguir?" | Qualquer um, por PR | Quando uma regra muda | Editado; regra nova cita o motivo |
| `CONTEXT.md` | "O que é o projeto e em que ordem fazemos?" | Quem fecha uma fase ou muda o escopo | Fim de fase, mudança de escopo | Editado |
| `JOURNAL.md` | "Onde a última sessão parou?" | Quem encerra a sessão | **Toda** sessão | **Sobrescrito** e commitado |
| `DEPENDENCIES.md` | "O que eu instalo para trabalhar?" | Quem adiciona ou troca uma ferramenta | Ferramenta nova, versão do jogo nova | Editado |
| `DOCS-GUIDE.md` | "Onde fica cada coisa?" | Quem cria um tipo novo de documento | Raro | Editado |
| `README.md` | "O que é isto e por onde começo?" (quem chega pelo GitHub) | Quem muda a fase, a licença ou o status do projeto | Raro | Editado; só aponta para os outros arquivos |
| `CHANGELOG.md` | "O que mudou para o jogador em cada versão?" | Todo PR com efeito visível | A cada PR | Só acréscimo, versão mais nova no topo |
| `specs/README.md` | "Quais specs existem e em que status?" | Quem cria ou muda o status de uma spec | A cada spec | Editado (índice) |
| `specs/NNN-*.md` | "Como esta funcionalidade se comporta, exatamente?" | Quem implementa a funcionalidade | Antes do código e no mesmo PR que muda o comportamento | Editado; status `rascunho → aprovada → implementada → obsoleta` |
| `specs/000-template.md` | Modelo de spec | Raro | Quando o formato de spec muda | Editado |
| `specs/checklist-mp.md` | Teste manual de multiplayer | Quem acha um caso novo | Antes de cada release | Editado |
| `specs/decisions/ADR-NNN-*.md` | "Por que decidimos assim?" | Quem toma uma decisão de arquitetura | Na decisão | **Nunca reescrito.** Decisão mudou? ADR nova que "substitui a ADR-NNN" |

## Cada arquivo em detalhe

### `CLAUDE.md`: as regras
O contrato do projeto: princípios, camadas, segurança, estilo de Lua, testes, Git e definição de pronto. Agentes de IA leem este arquivo automaticamente, e humanos devem ler antes do primeiro PR. Não guarda estado nem planos, só regras.

### `CONTEXT.md`: o mapa
A visão de cima: o que o mod faz, a arquitetura resumida, a árvore de pastas e as fases com prioridade. Aponta para o `CLAUDE.md` e para os docs de design em vez de repeti-los. Quando uma fase termina, marque-a no §6.

### `JOURNAL.md`: o "save" da sessão
Mostra só a **última** sessão, para que quem chega leia uma página e saiba o próximo passo. O ritual de fim de sessão e o modelo estão no `CLAUDE.md` §11.

Por que sobrescrever e não acumular: um diário que cresce sem parar vira um arquivo que ninguém lê, e agentes gastam contexto lendo sessões antigas. O custo é perder o histórico, por isso a regra exige **commit a cada sessão**: o Git guarda todas as versões (`git log -p -- JOURNAL.md`). Decisões que precisam durar não ficam no journal; vão para ADRs, specs ou `CHANGELOG.md`.

### `DEPENDENCIES.md`: o ambiente
Lista do que instalar, com versão e link, separada em obrigatório e opcional, mais a configuração das ferramentas e o passo a passo para testar em multiplayer local.

### `README.md`: a porta de entrada
É a página que o GitHub mostra primeiro. Diz em uma frase o que é o mod, em que fase está, a licença e para qual arquivo ir. Não repete conteúdo: aponta para o `CONTEXT.md`, o `CLAUDE.md`, o `DEPENDENCIES.md` e as `specs/`.

### `CHANGELOG.md`: o que mudou
Formato [Keep a Changelog](https://keepachangelog.com/pt-BR/1.1.0/): seções `Adicionado`, `Alterado`, `Corrigido`, `Removido` por versão, com a versão mínima do jogo. Texto pensado para quem administra servidor, não para programador.

### `specs/`: o comportamento
Uma spec por funcionalidade, no formato do `CLAUDE.md` §2.1. A numeração segue o doc de viabilidade: `001–002` base, `010–011` igrejas e spawn, `020–022` cerco, `030` morte, `040–041` economia, `050–051` buffs, `060–061` interface, `070–072` especiais. Faixas com folga permitem inserir specs sem renumerar.

### `specs/decisions/`: as ADRs
Curtas (cabeçalho com status e data, depois contexto, decisão e consequências), numeradas e imutáveis. Existentes: ADR-001 servidor autoritativo, ADR-002 progressão global, ADR-003 licença e dependências externas, ADR-004 ID do mod e namespace.

## Como organizar

- **Nomes:** arquivos de controle em MAIÚSCULAS na raiz (`CLAUDE.md`, `CONTEXT.md`...), specs e ADRs com número e nome curto em minúsculas (`020-maquina-cerco.md`).
- **Idioma:** documentos em PT-BR; identificadores e IDs técnicos em inglês (`CLAUDE.md` §6.1).
- **Links relativos** entre arquivos do repositório (`[CLAUDE.md](CLAUDE.md)`), para funcionarem no GitHub e no VS Code.
- **Datas** no formato `AAAA-MM-DD` ou `DD/MM/AAAA`, sempre absolutas, nunca "ontem".
- **Ordem de leitura** de quem chega ao projeto: `JOURNAL.md` → `CONTEXT.md` → `CLAUDE.md` → spec da tarefa.
- **Docs de design** (viabilidade, plano de arquitetura) vivem como Claude Docs, fora do repositório, e servem de discussão. O que for aprovado neles vira spec ou ADR **dentro** do repositório, que passa a ser a fonte da verdade.
