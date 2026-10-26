# ADR-005: nenhum caminho Lua repetido entre shared, client e server

- **Status:** aceita
- **Data:** 26/10/2026
- **Origem:** achado ao planejar o código da SPEC-001; decidida pela recomendação, sob a autonomia dada pelo Rodrigo em 26/10/2026

## Contexto

O `require` do Project Zomboid recebe um nome relativo (`require "ChurchRun/adapters/Clock"`) e procura o arquivo nas três pastas de Lua: `shared/`, `client/` e `server/`. A árvore antiga do `CLAUDE.md` §3.2 tinha `client/ChurchRun/Main.lua` e `server/ChurchRun/Main.lua`, e `adapters/` dos dois lados. Com isso, um adaptador com o mesmo nome no cliente e no servidor teria o mesmo nome de `require`, e qual arquivo carrega ficaria por conta do jogo (em single player as três pastas carregam juntas).

O jogo evita isso no próprio código: no 42.21.0 não há nenhum caminho relativo repetido entre as três pastas, e o vanilla usa prefixos (`Farming/CFarmingSystem.lua` no cliente, `Farming/SFarmingSystem.lua` no servidor). Conferido em 26/10/2026 comparando as listas de arquivos das três pastas da instalação.

## Decisão

Cada lado tem uma subpasta própria dentro de `ChurchRun/`, e assim nenhum caminho relativo se repete:

| Pasta | Conteúdo | Nome no `require` |
|---|---|---|
| `lua/shared/ChurchRun/` | `domain/`, `defs/`, `protocol/`, `util/` | `ChurchRun/protocol/commands` |
| `lua/client/ChurchRun/Client/` | `Main.lua`, `net/`, `ui/`, `adapters/` | `ChurchRun/Client/net/CommandClient` |
| `lua/server/ChurchRun/Server/` | `Main.lua`, `app/`, `ports/`, `rewards/`, `adapters/`, `migrations/` | `ChurchRun/Server/app/protocol/Router` |

As traduções continuam em `lua/shared/Translate/`, caminho exigido pelo jogo.

## Consequências

- Um adaptador pode ter o mesmo nome curto nos dois lados (`Client/adapters/Log.lua` e `Server/adapters/Log.lua`) sem colisão.
- Os nomes de `require` ficam um nível mais longos.
- Os testes (`busted`) usam as três pastas no `package.path`, como o jogo, e acham cada módulo sem ambiguidade.
