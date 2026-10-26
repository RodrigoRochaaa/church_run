# SPEC-NNN Título curto

- **Status:** rascunho
- **Versão mínima do jogo testada:** — (preencha quando houver teste no jogo)
- **Fase:** N (`CONTEXT.md` §6)
- **ADRs ligadas:** ADR-00X
- **Depende de:** SPEC-00X

## Objetivo

O problema que a spec resolve, em 2 a 3 frases.

## Fora do escopo

- O que esta spec não faz, e qual spec faz.

## Comportamento

- **R1.** Regra verificável, numerada. Uma ideia por regra.
- **R2.** ...

## Contrato

### Comandos de rede

| Comando | Direção | Argumentos (tipo e limites) | Rate limit | Resposta |
|---|---|---|---|---|
| `nomeDoComando` | cliente → servidor | `campo`: integer 1–10 | burst 3, 1 a cada 5 s | `outroComando` |

### Dados salvos

Formato salvo, com `schemaVersion`. Se não grava nada, diga isso.

### Eventos e API do jogo usados

| Uso | API | Conferido |
|---|---|---|
| ... | `Events.X` | onde e quando foi conferido, ou VERIFICAR B42 |

## Segurança

| O que um cliente malicioso tenta | Como o servidor recusa |
|---|---|
| ... | ... |

## Critérios de aceite

- **CA1** (R1). Dado ..., quando ..., então .... Teste: `tests/...` ou item do `checklist-mp.md`.
- Inclua cenários de erro e de multiplayer: dois jogadores, lag, desconexão.

## Impacto em dados

Muda o esquema salvo? Então: nova `schemaVersion`, migração e teste da migração. Se não muda, diga isso.

## Questões em aberto

Só enquanto a spec é rascunho. Cada questão traz a recomendação de quem escreveu. Some quando a spec é aprovada.
