# CONTEXT.md: o que estamos construindo e em que ordem

> Leia este arquivo primeiro. Ele dá a visão geral; as **regras** de código ficam no [`CLAUDE.md`](CLAUDE.md) e não são repetidas aqui.
> Última revisão: 26/10/2026.

---

## 1. O mod em uma frase

Um mod **multiplayer** para Project Zomboid **Build 42 (42.20+)** em que o grupo conquista, uma a uma, a igreja principal de cada cidade de Knox Country, sobrevivendo a ondas de zumbis com tempo marcado; cada vitória libera um novo ponto de nascimento, moedas, lojas e buffs.

- 100% Lua + scripts de item. Sem Java.
- O **servidor** decide tudo; o cliente só pede e mostra (ver `CLAUDE.md` §1 e §4).
- Gratuito e de código aberto (licença proposta: MIT para código, CC BY 4.0 para arte, a confirmar na ADR-003).

## 2. Documentos de referência

| Documento | Para que serve |
|---|---|
| [`CLAUDE.md`](CLAUDE.md) | Regras obrigatórias: camadas, segurança, estilo, testes, definição de pronto |
| [Plano de arquitetura (MP)](https://claude.ai/artifact/TbL7fUBqqyNAfFwZNwhjhQ) | Como mods de PZ funcionam, fluxo cliente/servidor, persistência |
| [Conquista de Igrejas: viabilidade e etapas](https://claude.ai/artifact/WojQe1M1D7Di5SrskpNkZT) | O design do jogo, veredictos de viabilidade, ondas, buffs, lista de specs |
| [`DOCS-GUIDE.md`](DOCS-GUIDE.md) | O que cada `.md` do projeto faz e como mantê-los |
| [`DEPENDENCIES.md`](DEPENDENCIES.md) | O que instalar para desenvolver e testar |
| [`JOURNAL.md`](JOURNAL.md) | Onde a última sessão parou e qual é o próximo passo |

## 3. O que será construído

O ciclo do jogo:

1. O grupo nasce no único spawn liberado (no começo, a cidade da Igreja 1).
2. Na igreja, alguém interage com o altar e inicia o **cerco**.
3. O servidor gera **ondas** de zumbis num anel de 50 a 90 tiles, que caminham até a igreja, por um tempo fixo.
4. Zumbis mortos no cerco deixam **moedas**. Quem morre fica numa área de espera até o cerco acabar.
5. Quando o tempo zera, a igreja é **conquistada**: recompensa paga uma vez por jogador vivo, ícone no mapa, novo spawn liberado e **escolha de buffs** (3 opções sorteadas, sem repetir).
6. As moedas compram armas, remédios, barricadas e roupas nas **lojas** da igreja. O catálogo cresce a cada igreja.

Ordem proposta das igrejas: Rosewood → Riverside → West Point → Muldraugh → Louisville (final). Progresso **global do servidor** (decidido em 26/10/2026, vira a ADR-002).

Funcionalidades, agrupadas por módulo:

| Módulo | O que faz | Specs |
|---|---|---|
| Base | Protocolo de comandos, persistência com `schemaVersion` | SPEC-001, SPEC-002 |
| Igrejas e spawn | Dados das igrejas; teleportar o personagem novo para o spawn liberado | SPEC-010, SPEC-011 |
| Cerco | Máquina de estados (preparo, onda, descanso, vitória, derrota), gerador de zumbis, tabela de ondas | SPEC-020 a 022 |
| Morte | Área de espera durante o cerco, perda total | SPEC-030 |
| Economia | Moeda (item), drop, lojas por igreja | SPEC-040, SPEC-041 |
| Buffs | Sorteio, posse, catálogo de 30 | SPEC-050, SPEC-051 |
| Interface | HUD lateral (onda, tempo, restantes, buffs), ícone no mapa | SPEC-060, SPEC-061 |
| Especiais | Corredores, zumbi tanque (protótipo), bandidos opcionais | SPEC-070 a 072 |

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

É a estrutura do `CLAUDE.md` §3.2, com as subpastas por funcionalidade que o design da conquista de igrejas pede. **Toda pasta nova segue as camadas**: uma funcionalidade aparece em `domain/`, `app/` e `adapters/`, nunca numa pasta que mistura tudo.

```
QuestMod/                                  # raiz do repositório = item do Workshop
  CLAUDE.md  CONTEXT.md  DOCS-GUIDE.md  DEPENDENCIES.md  JOURNAL.md  CHANGELOG.md  LICENSE
  workshop.txt  preview.png
  .emmyrc.json  .luacheckrc  .stylua.toml  # configuração das ferramentas (ver DEPENDENCIES.md)
  Contents/mods/QuestMod/
    common/                                # texturas, ícones, poster
    42/
      mod.info                             # id=QuestMod, versionMin=42.20
      media/
        scripts/QuestMod_items.txt         # moeda, itens de missão
        lua/shared/Translate/{EN,PTBR}/    # textos do jogador (VERIFICAR formato e nome da pasta PT-BR no B42.20)
        lua/shared/QuestMod/
          domain/   siege/ waves/ buffs/ economy/ churches/
          defs/     churches.lua waves.lua shops.lua buffs.lua
          protocol/ commands.lua schemas.lua version.lua
          util/
        lua/client/QuestMod/
          Main.lua
          net/                             # enviar pedidos, receber estado
          ui/       hud/ shop/ buffdraft/ map/
          adapters/                        # eventos de cliente, símbolos do mapa
        lua/server/QuestMod/
          Main.lua                         # liga ports a adapters
          app/      siege/ spawn/ death/ shop/ buffs/
          rewards/                         # um pagador por tipo (item, moeda, buff, unlock)
          adapters/ ZombieSpawner Teleport Traits Inventory Storage Net Log Players Clock
          migrations/
  specs/
    README.md  000-template.md  checklist-mp.md
    001-protocolo-comandos.md ...
    decisions/ ADR-001-servidor-autoritativo.md  ADR-002-progressao-global.md  ADR-003-licenca.md
  tests/                                   # busted, Lua 5.1, ports falsos
  tools/                                   # lint, empacotar, checar "API do jogo fora de adapters/"
```

Por que a raiz do repositório é o item do Workshop: o jogo procura mods em `C:\Users\<você>\Zomboid\Workshop\<Item>\Contents\mods\...`. Com um link (junction) dessa pasta para o repositório, você edita no VS Code e o jogo lê na hora, sem copiar arquivos. O passo a passo está no `DEPENDENCIES.md`.

## 6. Prioridades e fases

Regra de prioridade: **primeiro uma fatia jogável de ponta a ponta (Igreja 1), depois largura.** Nada de loja, buff ou zumbi especial antes de um cerco funcionar em multiplayer com dois clientes.

Cada fase só começa quando as decisões de design que ela usa (D1 a D6, no doc de viabilidade) estiverem fechadas, e termina com algo testável num servidor com dois clientes.

| Fase | Entrega | Specs / ADRs | Decisões antes | Pronto quando |
|---|---|---|---|---|
| **0. Fundação** | Repositório, ferramentas, esqueleto do mod, ping cliente↔servidor, protocolo e persistência | ADR-001/002/003, SPEC-001, 002 | Licença, nome do mod | Mod carrega nos dois lados; comando inválido recusado e logado; dados sobrevivem a reiniciar o servidor |
| **1. Igreja 1 jogável** | Dados da Igreja 1, spawn liberado, cerco com timer, ondas, morte com área de espera, HUD mínimo (onda e tempo) | SPEC-010, 011, 020, 021, 022, 030, parte da 060 | D1, D2, D6 | Dois jogadores conquistam Rosewood; vitória paga uma vez; spawn muda para a próxima cidade |
| **2. Economia** | Moeda como item, drop no cerco, loja com 4 abas | SPEC-040, 041 | D3, D4 | Compra validada no servidor; clique duplo não cobra duas vezes |
| **3. Buffs** | Sorteio de 3, posse por personagem, perda na morte | SPEC-050, 051 | D5 | Sorteio sem repetição nos dois clientes; buff some ao morrer |
| **4. Interface completa** | HUD completo, ícone de igreja vencida no mapa | SPEC-060, 061 | — | Ícone aparece para quem entra depois da conquista |
| **5. Igrejas 2 a 5** | Dados e balanceamento das outras igrejas, corredores | SPEC-010 (dados), 070 | D1, D6 | Campanha completa jogável |
| **6. Especiais (opcional)** | Zumbi tanque (protótipo), bandidos via Bandits NPC se instalado | SPEC-071, 072 | — | Protótipo estável em MP, ou descartado com registro na ADR |
| **7. Publicação** | Checklist de MP, poster, página do Workshop, versão 1.0 | — | — | Checklist de MP do `CLAUDE.md` §7 todo marcado |

O roteiro de 9 etapas do plano de arquitetura continua valendo para a Fase 0 (etapas 1 a 3). As etapas de "missões genéricas" (tipos de objetivo, gerador de missões) ficam **fora da v1**: o motor de recompensas é reaproveitado pelo cerco e pela loja, e o registro de objetivos só é construído quando uma spec pedir.

## 7. Questões em aberto

- **Nome do mod.** O ID técnico ainda é `QuestMod`, de quando o projeto era um mod de missões. Trocar depois do primeiro release quebra saves e a linha `Mods=` dos servidores; trocar agora custa só um buscar-e-substituir. Recomendo decidir antes da Fase 0.
- **Repositório.** Ainda não existe repositório Git; os arquivos estão na pasta do projeto. Criar o repositório no GitHub é o primeiro passo da Fase 0 (ver `DEPENDENCIES.md`).
- Decisões D1 a D6 do doc de viabilidade: moeda fora do cerco, corpo do morto, 5 ou 4 igrejas, catálogo, lista de buffs, tabela de ondas.
