# specs/: índice

Uma spec por funcionalidade, no formato do `CLAUDE.md` §2.1 (modelo: [`000-template.md`](000-template.md)). Status: `rascunho` → `aprovada` → `implementada` → `obsoleta`. A numeração por módulo está no `DOCS-GUIDE.md`; as specs ainda não escritas estão no `CONTEXT.md` §3.

## Specs

| Spec | Título | Status | Fase | Versão do jogo testada |
|---|---|---|---|---|
| [SPEC-001](001-protocolo-comandos.md) | Protocolo de comandos | aprovada | 0 | — |
| [SPEC-002](002-persistencia.md) | Persistência | aprovada | 0 | — |

## ADRs

| ADR | Decisão | Status |
|---|---|---|
| [ADR-001](decisions/ADR-001-servidor-autoritativo.md) | Servidor autoritativo | aceita |
| [ADR-002](decisions/ADR-002-progressao-global.md) | Progressão global do servidor | aceita |
| [ADR-003](decisions/ADR-003-licenca.md) | Licença e dependências externas | aceita |
| [ADR-004](decisions/ADR-004-id-e-namespace.md) | ID do mod `church_run` e namespace `ChurchRun` | aceita |
| [ADR-005](decisions/ADR-005-caminhos-lua-unicos.md) | Nenhum caminho Lua repetido entre shared, client e server | aceita |

## Teste manual

[`checklist-mp.md`](checklist-mp.md): checklist de multiplayer, obrigatório antes de cada release.
