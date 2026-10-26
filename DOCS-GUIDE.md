# DOCS-GUIDE.md: para que serve cada arquivo .md

> Regra geral: **cada informação mora em um lugar só.** Os outros arquivos apontam para ela com um link. Se você se pegar copiando um parágrafo de um `.md` para outro, troque a cópia por um link.

## Mapa rápido

| Arquivo | Pergunta que responde | Quem atualiza | Quando | Como muda |
|---|---|---|---|---|
| `CLAUDE.md` | "Quais regras eu tenho que seguir?" | Qualquer um, por PR | Quando uma regra muda | Editado; regra nova cita o motivo |
| `CONTEXT.md` | "O que é o projeto e em que ordem fazemos?" | Quem fecha uma fase ou muda o escopo | Fim de fase, mudança de escopo | Editado |
| `design/church_run_gdd.md` | "O que o jogo é, com números e decisões?" (manda no **o quê**) | O Rodrigo, ou alguém com a aprovação dele | Decisão de design nova; resultado de prova técnica (§12 e §5.4) | Editado; decisão nova entra no §1.2 com a data |
| `design/lojas.md`, `design/buffs.md` | Anexos do GDD: catálogo das lojas; buffs candidatos e regras do sorteio | Como o GDD | Como o GDD | Editado; versão nova substitui a antiga, que fica no Git |
| `design/coleta-mapa.md` | "Como coleto no jogo os pontos de uma igreja?" | Quem muda os pontos da SPEC-010 | Quando a SPEC-010 muda | Editado; os pontos coletados vão para `defs/`, não para este arquivo |
| `ROADMAP.md` | "Que passo vem agora e do que ele depende?" (manda no **quando**) | Quem toca um passo | Toda sessão que muda um status | Editado (status e passos) |
| `GUIA-CLAUDE.md` | "Como escolho o próximo passo, o que pesquiso e como aviso o Rodrigo?" | Quem muda o jeito de trabalhar | Raro | Editado |
| `PROMPT-SESSAO.md` | "O que colo no início de cada sessão?" | Quem muda o ritual de sessão | Raro | Editado |
| `research/AAAA-MM-DD-*.md` | "O que a prova técnica descobriu?" | Quem faz a prova | Ao fim de cada prova | Criado uma vez; não se reescreve |
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
A visão de cima: o que o mod faz, a arquitetura resumida, a árvore de pastas e as fases com prioridade. Aponta para o GDD, o `ROADMAP.md` e o `CLAUDE.md` em vez de repeti-los. Quando uma fase termina, marque-a no §6.

### `design/`: o GDD e os anexos
O GDD é a referência do design: o que o jogo é, com números, decisões tomadas (§1.2), riscos técnicos (§12), specs a escrever (§13) e decisões em aberto (§14). `lojas.md` e `buffs.md` detalham partes dele. Mudança no GDD precisa do Rodrigo; a única exceção é atualizar o §12 e o §5.4 com o resultado de uma prova técnica (`GUIA-CLAUDE.md` §2).

### `ROADMAP.md`, `GUIA-CLAUDE.md` e `PROMPT-SESSAO.md`: como o trabalho anda
O ROADMAP quebra as fases do `CONTEXT.md` §6 em passos (P00, P01...) com dependências e status. O GUIA diz como escolher o próximo passo, o que pesquisar e como avisar o Rodrigo. O PROMPT-SESSAO é o texto colado no início de cada sessão, com a ordem de leitura e o ritual de fim.

### `research/`: as provas técnicas
Um relatório por prova, em `research/AAAA-MM-DD-nome.md`, com pergunta, o que foi testado, resposta (sim, não ou parcial), evidência e impacto no GDD. O formato está no `GUIA-CLAUDE.md` §2.

### `JOURNAL.md`: o "save" da sessão
Mostra só a **última** sessão, para que quem chega leia uma página e saiba o próximo passo. O ritual de fim de sessão e o modelo estão no `CLAUDE.md` §11.

Por que sobrescrever e não acumular: um diário que cresce sem parar vira um arquivo que ninguém lê, e agentes gastam contexto lendo sessões antigas. O custo é perder o histórico, por isso a regra exige **commit a cada sessão**: o Git guarda todas as versões (`git log -p -- JOURNAL.md`). Decisões que precisam durar não ficam no journal; vão para o GDD §1.2, ADRs, specs ou `CHANGELOG.md`.

### `DEPENDENCIES.md`: o ambiente
Lista do que instalar, com versão e link, separada em obrigatório e opcional, mais a configuração das ferramentas e o passo a passo para testar em multiplayer local.

### `README.md`: a porta de entrada
É a página que o GitHub mostra primeiro. Diz em uma frase o que é o mod, em que fase está, a licença e para qual arquivo ir. Não repete conteúdo: aponta para o `CONTEXT.md`, o GDD, o `ROADMAP.md`, o `CLAUDE.md`, o `DEPENDENCIES.md` e as `specs/`.

### `CHANGELOG.md`: o que mudou
Formato [Keep a Changelog](https://keepachangelog.com/pt-BR/1.1.0/): seções `Adicionado`, `Alterado`, `Corrigido`, `Removido` por versão, com a versão mínima do jogo. Texto pensado para quem administra servidor, não para programador.

### `specs/`: o comportamento
Uma spec por funcionalidade, no formato do `CLAUDE.md` §2.1. A numeração segue o GDD §13: `001–002` base, `010–012` mundo (igrejas, nascimento, teleporte), `020–022` cerco, `030` morte, `040–043` economia, `050–051` buffs, `060–062` interface, `070–079` zumbis (070 base, uma por especial a partir da 071, 079 bandidos), `080–082` missões. Faixas com folga permitem inserir specs sem renumerar.

### `specs/decisions/`: as ADRs
Curtas (cabeçalho com status e data, depois contexto, decisão e consequências), numeradas e imutáveis. Existentes: ADR-001 servidor autoritativo, ADR-002 progressão global, ADR-003 licença e dependências externas, ADR-004 ID do mod e namespace, ADR-005 caminhos Lua únicos entre shared, client e server.

## Como organizar

- **Nomes:** arquivos de controle em MAIÚSCULAS na raiz (`CLAUDE.md`, `CONTEXT.md`...), specs e ADRs com número e nome curto em minúsculas (`020-maquina-cerco.md`).
- **Idioma:** documentos em PT-BR; identificadores e IDs técnicos em inglês (`CLAUDE.md` §6.1).
- **Links relativos** entre arquivos do repositório (`[CLAUDE.md](CLAUDE.md)`), para funcionarem no GitHub e no VS Code.
- **Datas** no formato `AAAA-MM-DD` ou `DD/MM/AAAA`, sempre absolutas, nunca "ontem".
- **Ordem de leitura** de quem chega ao projeto: `JOURNAL.md` → `CONTEXT.md` → `CLAUDE.md` → `GUIA-CLAUDE.md` → `ROADMAP.md` → GDD → spec da tarefa (é a ordem do `PROMPT-SESSAO.md`).
- **Quem manda em quê** (`GUIA-CLAUDE.md` §6): o GDD manda no **o quê**, o `CLAUDE.md` no **como** e o `ROADMAP.md` no **quando**. Specs e ADRs detalham e registram; quando um deles contradiz o GDD, a contradição vira pergunta ao Rodrigo.
- **Docs de design fora do repositório:** os Claude Docs (viabilidade, plano de arquitetura) são histórico e discussão. O que for aprovado neles entra no GDD, numa spec ou numa ADR, dentro do repositório.
