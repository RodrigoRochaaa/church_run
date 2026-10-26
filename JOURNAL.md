# JOURNAL.md: onde paramos

> Este arquivo é **sobrescrito** ao fim de cada sessão (regra no `CLAUDE.md` §11). Ele mostra só a última sessão.
> O histórico completo fica no Git: `git log -p -- JOURNAL.md`. Por isso, ao fim da sessão, o journal novo é commitado.

**Data:** 26/10/2026
**Sessão:** Documentação de contexto e arquitetura
**Fase atual:** antes da Fase 0 (só design e documentação; nenhum código ainda)

## Próximo passo

Decidir o nome/ID técnico do mod (manter `QuestMod` ou trocar) e criar o repositório no GitHub. Depois, seguir o `DEPENDENCIES.md` para montar o ambiente e começar a Fase 0 do `CONTEXT.md`.

## O que foi feito

- Criados `CONTEXT.md` (visão geral, pastas, fases), `DOCS-GUIDE.md` (guia dos `.md`), `DEPENDENCIES.md` (ferramentas) e este `JOURNAL.md`.
- Adicionada ao `CLAUDE.md` a seção 11 (ritual de fim de sessão e regra de sobrescrita do journal).

## Decisões tomadas

- Journal sobrescrito a cada sessão, com histórico preservado pelo Git.
- Prioridade: fatia jogável da Igreja 1 antes de economia, buffs e especiais.
- Missões genéricas (objetivos, gerador) ficam fora da v1.

## Pendências e bloqueios

- Nome do mod (ver `CONTEXT.md` §7).
- Repositório Git ainda não existe.
- Decisões de design D1 a D6 (doc de viabilidade).
- Lacuna no `CLAUDE.md` §3.4: a UI precisa das classes ISUI do jogo (`ISPanel` etc.), mas a regra diz "API do jogo só em adapters/". O `.luacheckrc` proposto já libera `ui/`; falta registrar a exceção no `CLAUDE.md`.

## Arquivos tocados

`CONTEXT.md`, `DOCS-GUIDE.md`, `DEPENDENCIES.md`, `JOURNAL.md`, `CLAUDE.md`
