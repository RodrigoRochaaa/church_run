# CONTEXT.md: o que estamos construindo e em que ordem

> Leia este arquivo primeiro. Ele é o mapa do projeto: aponta onde cada coisa está e não repete o que mora em outro lugar.
> O **o quê** está no GDD ([`design/church_run_gdd.md`](design/church_run_gdd.md)), o **como** no [`CLAUDE.md`](CLAUDE.md) e o **quando** no [`ROADMAP.md`](ROADMAP.md) (`GUIA-CLAUDE.md` §6).
> Última revisão: 26/10/2026.

---

## 1. O mod em uma frase

Um mod **multiplayer** para Project Zomboid **Build 42 (42.20+)** em que o grupo atravessa Knox Country conquistando a igreja de 5 cidades vizinhas, uma a uma. Cada conquista é um cerco de ondas de zumbis com tempo marcado e libera um novo ponto de nascimento, teleporte, lojas maiores e buffs. O ciclo completo está no GDD §1.

- 100% Lua + scripts de item. Sem Java.
- O **servidor** decide tudo; o cliente só pede e mostra (`CLAUDE.md` §1 e §4, [ADR-001](specs/decisions/ADR-001-servidor-autoritativo.md)).
- Progresso global do servidor ([ADR-002](specs/decisions/ADR-002-progressao-global.md)).
- Gratuito e de código aberto: MIT para o código e CC BY 4.0 para a arte ([ADR-003](specs/decisions/ADR-003-licenca.md)).
- ID do mod `church_run`, namespace do código `ChurchRun` ([ADR-004](specs/decisions/ADR-004-id-e-namespace.md)).

## 2. Documentos de referência

| Documento | Para que serve |
|---|---|
| [`design/church_run_gdd.md`](design/church_run_gdd.md) | O jogo: cidades, cerco, zumbis, economia, missões, buffs, interface, riscos, specs a escrever e decisões em aberto (§14) |
| [`design/lojas.md`](design/lojas.md) e [`design/buffs.md`](design/buffs.md) | Anexos do GDD: catálogo com IDs e preços; os 81 buffs candidatos e as regras do sorteio |
| [`ROADMAP.md`](ROADMAP.md) | Os passos de cada fase, com dependências e status |
| [`GUIA-CLAUDE.md`](GUIA-CLAUDE.md) | Como escolher o próximo passo, o que pesquisar e como avisar o Rodrigo |
| [`PROMPT-SESSAO.md`](PROMPT-SESSAO.md) | O prompt de início de sessão: ler, confirmar, executar e encerrar |
| [`CLAUDE.md`](CLAUDE.md) | Regras obrigatórias: camadas, segurança, estilo, testes, definição de pronto |
| [`specs/`](specs/README.md) | Specs e ADRs: o comportamento exato de cada funcionalidade e o porquê das decisões |
| [`DOCS-GUIDE.md`](DOCS-GUIDE.md) | O que cada `.md` do projeto faz e como mantê-los |
| [`DEPENDENCIES.md`](DEPENDENCIES.md) | O que instalar para desenvolver e testar |
| [`JOURNAL.md`](JOURNAL.md) | Onde a última sessão parou e qual é o próximo passo |
| [Plano de arquitetura (MP)](https://claude.ai/artifact/TbL7fUBqqyNAfFwZNwhjhQ) | Como mods de PZ funcionam, fluxo cliente/servidor, persistência |
| [Conquista de Igrejas: viabilidade e etapas](https://claude.ai/artifact/WojQe1M1D7Di5SrskpNkZT) | Histórico. A parte de design foi substituída pelo GDD v0.2 |

## 3. O que será construído

O design está no GDD, e este arquivo não repete os números dele:

- ciclo do jogo e decisões já tomadas: GDD §1;
- cidades, nascimento e teleporte: GDD §2;
- dificuldade, cerco, zumbis, economia, missões e buffs: GDD §3 a §8;
- interface e opções de sandbox: GDD §9 e §10;
- riscos técnicos a provar antes das specs: GDD §12;
- lista de specs por módulo: GDD §13.

## 4. Arquitetura em resumo

As camadas e as regras de dependência estão no `CLAUDE.md` §3. Resumo visual:

```
cliente (ui, net)  ──pedido──▶  servidor: Router ─▶ app (casos de uso) ─▶ domain (regras puras)
        ▲                                             │
        └──────── estado completo (sync) ◀────────────┴─▶ ports ─▶ adapters ─▶ API do PZ B42
```

- `domain`: regra pura e testável fora do jogo (fórmula das ondas, máquina de estados do cerco, sorteio de buffs, preços).
- `app`: casos de uso do servidor (`StartSiege`, `AdvanceSiege`, `BuyItem`, `PickBuff`...).
- `ports` / `adapters`: tudo que toca o jogo (gerar zumbi, teleportar, dar trait, inventário, ModData, rede). Patch do jogo quebrou algo? A correção cabe num adaptador.
- `defs`: números e catálogos em dados (igrejas, ondas, lojas, buffs), ajustáveis sem mexer em código.

## 5. Estrutura de pastas

É a estrutura do `CLAUDE.md` §3.2, com as subpastas por funcionalidade que o design pede. **Toda pasta nova segue as camadas**: uma funcionalidade aparece em `domain/`, `app/` e `adapters/`, nunca numa pasta que mistura tudo.

```
church_run/                                # raiz do repositório = item do Workshop (a pasta local pode ter outro nome)
  CLAUDE.md  CONTEXT.md  DOCS-GUIDE.md  DEPENDENCIES.md  JOURNAL.md  CHANGELOG.md  README.md  LICENSE
  GUIA-CLAUDE.md  ROADMAP.md  PROMPT-SESSAO.md
  workshop.txt  preview.png                # só na publicação (Fase 7)
  .luacheckrc  .stylua.toml  .emmyrc.example.json  .gitattributes  .gitignore   # ferramentas (ver DEPENDENCIES.md)
  .github/workflows/ci.yml                 # lint e testes a cada push e PR
  design/                                  # o "o quê": church_run_gdd.md, lojas.md, buffs.md
  research/                                # relatórios das provas técnicas: AAAA-MM-DD-nome.md (GUIA-CLAUDE.md §2)
  Contents/mods/church_run/
    common/                                # texturas, ícones, poster (o B42 espera a pasta, mesmo vazia)
    42/
      mod.info                             # id=church_run, versionMin=42.20.0
      media/
        scripts/ChurchRun_items.txt        # itens do mod (relíquias, kit de primeiros socorros...)
        lua/shared/Translate/{EN,PTBR}/    # textos do jogador em JSON (conferido no B42.21.0 em 26/10/2026)
        lua/shared/ChurchRun/
          domain/   siege/ waves/ buffs/ economy/ churches/
          defs/     churches.lua waves.lua shops.lua buffs.lua
          protocol/ commands.lua schemas.lua version.lua
          util/
        lua/client/ChurchRun/Client/       # caminhos únicos entre os lados (ADR-005)
          Main.lua
          net/                             # enviar pedidos, receber estado
          ui/       hud/ shop/ buffdraft/ map/
          adapters/                        # eventos de cliente, símbolos do mapa
        lua/server/ChurchRun/Server/
          Main.lua                         # liga ports a adapters
          app/      siege/ spawn/ death/ shop/ buffs/
          ports/                           # contratos que o app usa (Storage, Clock, Log, Net, Players...)
          rewards/                         # um pagador por tipo (item, moeda, buff, unlock)
          adapters/ ZombieSpawner Teleport Traits Inventory Storage Net Log Players Clock
          migrations/
  specs/
    README.md  000-template.md  checklist-mp.md
    001-protocolo-comandos.md  002-persistencia.md ...
    decisions/ ADR-001-servidor-autoritativo.md  ADR-002-progressao-global.md  ADR-003-licenca.md  ADR-004-id-e-namespace.md  ADR-005-caminhos-lua-unicos.md
  tests/                                   # busted, Lua 5.1, ports falsos
  tools/                                   # lint, empacotar, checar "API do jogo fora de adapters/"
```

Por que a raiz do repositório é o item do Workshop: o jogo procura mods em `C:\Users\<você>\Zomboid\Workshop\<Item>\Contents\mods\...`. Com um link (junction) dessa pasta para o repositório, você edita no VS Code e o jogo lê na hora, sem copiar arquivos. O passo a passo está no `DEPENDENCIES.md`.

## 6. Prioridades e fases

Regra de prioridade: **primeiro uma fatia jogável de ponta a ponta (Igreja 1), depois largura.** Nada de loja, buff ou zumbi especial antes de um cerco funcionar em multiplayer com dois clientes.

Cada fase começa pelas provas técnicas dela (GDD §12) e só começa quando as decisões do GDD §14 que ela usa estiverem fechadas. Toda fase termina com algo testável num servidor com dois clientes. Os passos de cada fase, com dependências e status, estão no [`ROADMAP.md`](ROADMAP.md).

| Fase | Entrega (passos do ROADMAP) | Decisões antes (GDD §14) | Pronto quando |
|---|---|---|---|
| **0. Fundação** (em andamento) | Repositório, ferramentas, esqueleto do mod, protocolo e persistência (P00 a P02) | Licença e nome do mod (fechadas em 26/10/2026) | Mod carrega nos dois lados; comando inválido recusado e logado; dados sobrevivem a reiniciar o servidor |
| **1. Igreja 1 jogável** | Provas de teleporte, spawn e painel; dados de Rosewood; Kit do Peregrino com a relíquia; cerco, morte, nascimento e HUD mínimo (P03 a P11) | #1 cadeia de cidades, #5 corpo do morto | Dois jogadores conquistam Rosewood; vitória paga uma vez; spawn muda para a próxima cidade |
| **2. Economia** | Atribuição do abate, moedas, Loja Básica e loja da igreja 1, conserto no altar (P12 a P15) | #2 carteira ou moeda física | Compra validada no servidor; clique duplo não cobra duas vezes |
| **3. Buffs** | Sorteio de 3, reroll, posse por personagem, perda na morte (P16, P17) | #8 os 30 buffs | Sorteio sem repetição nos dois clientes; buff some ao morrer |
| **4. Interface completa** | HUD completo e ícones no mapa (P18, P19) | — | Ícone aparece para quem entra depois da conquista |
| **5. Igrejas 2 a 5** | Corredor e base dos especiais, dados das igrejas 2 a 5, teleporte, relíquia escondida (P20 a P24) | #1 cadeia, #3 teleporte, #4 descontos, #9 missões | Campanha completa jogável |
| **6. Zumbis especiais** | Especiais do GDD §5.3 e bandidos opcionais (P25 a P29) | #7 o Bispo | Cada especial estável em MP, ou descartado com registro no GDD §12 |
| **7. Publicação** | Sandbox, traduções, poster, página da Oficina, checklist de MP (P30, P31) | — | Checklist de MP do `CLAUDE.md` §7 todo marcado |

O roteiro de 9 etapas do plano de arquitetura vale para a Fase 0 (etapas 1 a 3). O resto dele (missões genéricas, gerador de missões) foi substituído pelo GDD §7 e pelo ROADMAP.

## 7. Questões em aberto

As decisões de design em aberto estão no GDD §14. A tabela do §6 mostra qual fase cada uma bloqueia; a #6 (contra-ataques) só pesa depois da 1.0.
