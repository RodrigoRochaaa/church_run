# ADR-004: ID do mod `church_run` e namespace `ChurchRun`

- **Status:** aceita
- **Data:** 26/10/2026
- **Origem:** decisão do Rodrigo em 26/10/2026 (antiga questão "Nome do mod" do `CONTEXT.md` §7)

## Contexto

O ID técnico era `QuestMod`, de quando o projeto era um mod de missões. Ele é genérico, o que aumenta o risco de colisão com outros mods, e já não descreve o mod. Trocar o ID depois do primeiro release quebra saves e a linha `Mods=` dos servidores; antes de existir código, a troca custa só um buscar-e-substituir.

## Decisão

| Onde | Nome |
|---|---|
| `id` no `mod.info`, linha `Mods=\church_run`, pasta `Contents/mods/church_run/`, pasta do item no Workshop, repositório no GitHub | `church_run` |
| Pastas Lua (`lua/shared/ChurchRun/` etc.), tabela global, módulo dos comandos de rede, `module` dos scripts de item, prefixo das chaves de Global ModData (`ChurchRun_World`) e das chaves de tradução | `ChurchRun` |

`ChurchRun` segue o `PascalCase` de módulos do `CLAUDE.md` §6.1. O nome exibido na lista de mods ("Church Run", no `mod.info`) não é ID técnico e pode mudar a qualquer momento.

Em 26/10/2026 a busca no Workshop do Project Zomboid por `church_run`, `ChurchRun` e "church run" não achou mod com esse nome, e nenhum dos 62 mods assinados na máquina de desenvolvimento usa esse ID. O Workshop não indexa o ID do mod, então a busca cobre títulos e descrições.

## Consequências

- Mudar qualquer um dos dois nomes depois do primeiro release é mudança major (`CLAUDE.md` §8), com migração das chaves de ModData.
- O lint (`.luacheckrc`) só aceita o global `ChurchRun`.
