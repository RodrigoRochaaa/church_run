# JOURNAL.md: onde paramos

> Este arquivo é **sobrescrito** ao fim de cada sessão (regra no `CLAUDE.md` §11). Ele mostra só a última sessão.
> O histórico completo fica no Git: `git log -p -- JOURNAL.md`. Por isso, ao fim da sessão, o journal novo é commitado.

**Data:** 26/10/2026
**Sessão:** Dedicated Server instalado e P02 testado no servidor real (bug do `next` achado e corrigido)
**Fase atual:** Fase 0 (Fundação), em andamento. No `ROADMAP.md`: P00 aguardando teste (só a lista de mods no cliente), P01 concluído, P02 aguardando teste (cliente e merge dos PRs #1 e #2).

## Próximo passo

1. **Rodrigo (cerca de 15 min):** o repositório já está na branch `spec-002-persistencia`, que inclui os dois PRs e é a que o jogo lê pelo link.
   - Abrir o jogo com `-debug` e ver "Church Run" na lista de mods. Isso fecha o P00.
   - Seguir os checklists "Teste no jogo" do [PR #1](https://github.com/RodrigoRochaaa/church_run/pull/1) e do [PR #2](https://github.com/RodrigoRochaaa/church_run/pull/2). O servidor de teste sobe com `tools\start-dev-server.bat "D:\apps de jogo\steamapps\common\Project Zomboid Dedicated Server"`.
   - Se passar: mesclar o #1 e depois o #2, completar "Versão mínima do jogo testada" nas specs com o lado do cliente e marcar o P02 como concluído.
2. **Claude, com o P00 fechado:** escrever a SPEC-010 (igrejas e âncoras) e o roteiro de coleta do P06 para Rosewood (`GUIA-CLAUDE.md` §2, "Dados do mapa").

## O que foi feito

- **Dedicated Server instalado** pelo atalho `steam://install/380870` (build 25485538, 7,1 GB). O `DEPENDENCIES.md` agora explica que ele fica escondido em "Ferramentas" na Biblioteca da Steam.
- **Servidor de teste `churchrun_dev`** (sem Steam, até 5 GB), subido 5 vezes por script com `quit` no fim, sem tocar no `servertest` do jogo. Achados:
  - o servidor dedicado só lê mods locais de `Zomboid\mods`. O link de desenvolvimento passou do Workshop para `Zomboid\mods\church_run`, que o jogo também lê;
  - **bug:** o Kahlua não tem `next`. Quebrou a carga do `WorldStore` (o `pcall` segurou, e o servidor ficou em modo seguro) e teria quebrado a varredura do rate limit. Correção com `pairs` (`Tables.isEmpty`), testes de regressão sem `next` e lint com o std `kahlua`, montado a partir das bibliotecas do `projectzomboid.jar` (`CLAUDE.md` §6.2);
  - **persistência:** SPEC-002 CA1 e CA2 conferidos, com `bootCount` 1, 2 e 3 e o mesmo `createdAtMs`. O `OnInitGlobalModData` roda antes do `SERVER STARTED`;
  - **log limpo:** pastas vazias `media/AnimSets` e `media/actiongroups` no esqueleto eliminam 4 linhas de ERROR que o jogo registra para mods sem elas;
  - **traduções:** pelas strings do jar, o tradutor soma o `UI.json` de cada mod ao do jogo. O "overrides" do log é só o sistema de arquivos.
- `tools\start-dev-server.bat` sobe o servidor sem o `StartServer64.bat`, que reserva 16 GB e só repassa dois argumentos. Ajustados o `DEPENDENCIES.md` (§3 passo 8 e §5 B) e o `CONTEXT.md` §5.
- PRs atualizados, com os resultados do servidor nas descrições: #1 com 74 testes e #2 com 101, lint com 0 avisos.

## Decisões tomadas

Pela autonomia dada pelo Rodrigo em 26/10/2026, todas reversíveis:

- Link de desenvolvimento em `Zomboid\mods\church_run`; o link do Workshop volta só na publicação (Fase 7).
- Servidor de teste separado, `churchrun_dev`, com config em `%USERPROFILE%\Zomboid\Server\churchrun_dev.ini`.
- O lint do código do mod passa a usar o std `kahlua` (só o que existe no jogo); os testes continuam no Lua 5.1 completo.
- Pastas vazias de animação no esqueleto do mod, para o log do servidor não acusar ERROR.

## Pendências e bloqueios

- Teste com cliente (Rodrigo) e merge dos PRs, na ordem #1 e depois #2.
- VERIFICAR B42 que só o teste com cliente responde:
  - a resposta em single player por `triggerEvent`;
  - o `OnCreatePlayer` dispara depois de o servidor aceitar pedidos;
  - onde o `writeLog` grava;
  - uma Global ModData transmitida pelo cliente não é gravada.
- Decisões do GDD §14 por fase, sem mudança: Fase 1, #1 e #5; Fase 2, #2; Fase 3, #8; Fase 5, #3, #4 e #9; Fase 6, #7; depois da 1.0, #6.
- Para specs futuras:
  - risco de farmar o Kit do Peregrino (P06a);
  - a posição da relíquia escondida não pode ficar na Global ModData (SPEC-080);
  - item dado pelo servidor precisa aparecer no cliente (VERIFICAR do P06a).
- WSL para rodar os testes no próprio PC; até lá, o CI roda tudo.

## Arquivos tocados

Na `main`: `DEPENDENCIES.md`, `CONTEXT.md`, `ROADMAP.md`, `JOURNAL.md`, `tools/start-dev-server.bat` e as pastas vazias em `Contents/mods/church_run/{common,42}/media/{AnimSets,actiongroups}/`. Nos PRs: `.luacheckrc`, `CLAUDE.md` §6.2, `RateLimiter.lua`, `Tables.lua`, `WorldStore.lua`, os testes de regressão e as duas specs. Fora do repositório: `%USERPROFILE%\Zomboid\mods\church_run` (link novo), `%USERPROFILE%\Zomboid\Server\churchrun_dev.ini` e o save `churchrun_dev`.
