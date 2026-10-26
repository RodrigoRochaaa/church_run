# JOURNAL.md: onde paramos

> Este arquivo é **sobrescrito** ao fim de cada sessão (regra no `CLAUDE.md` §11). Ele mostra só a última sessão.
> O histórico completo fica no Git: `git log -p -- JOURNAL.md`. Por isso, ao fim da sessão, o journal novo é commitado.

**Data:** 26/10/2026
**Sessão:** Fundação: repositório e documentos, P02 implementado e testado no servidor dedicado, P00 concluído, P06 preparado
**Fase atual:** Fase 0 (Fundação), em andamento. No `ROADMAP.md`: P00 e P01 concluídos; P02 aguardando teste com cliente (PRs #1 e #2, prontos para mesclar); P06 aguardando a coleta do Rodrigo.

## Próximo passo

1. **Rodrigo:** o repositório está na branch `spec-002-persistencia`, que inclui os dois PRs e é a que o jogo lê pelo link `Zomboid\mods\church_run`.
   - Rodar os checklists "Teste no jogo" do [PR #1](https://github.com/RodrigoRochaaa/church_run/pull/1) e do [PR #2](https://github.com/RodrigoRochaaa/church_run/pull/2). Se passar, mesclar o #1 e depois o #2.
   - Coletar os pontos de Rosewood pelo [`design/coleta-mapa.md`](design/coleta-mapa.md) e colar a lista no chat.
2. **Claude, com a lista de Rosewood:** conferir as distâncias e abrir o PR da [SPEC-010](specs/010-igrejas.md), com `shared/ChurchRun/defs/churches.lua`, a conferência pura em `shared/ChurchRun/domain/churches/` e os testes dos CA1 a CA6. Com o P02 mesclado, ficam desbloqueadas as provas técnicas P03, P04 e P05 (`GUIA-CLAUDE.md` §1).

## O que foi feito

- **Repositório:**
  - `church_run` público no GitHub, com e-mail noreply e CI no GitHub Actions (luacheck e busted);
  - o `.git` vazio que existia na raiz `D:\` foi apagado;
  - `CLAUDE .md` virou `CLAUDE.md` e ganhou a §11;
  - o mod virou `church_run` / `ChurchRun` (ADR-004).
- **Documentos:**
  - GDD v0.2, lojas e buffs em `design/`;
  - `GUIA-CLAUDE.md`, `ROADMAP.md` e o novo `PROMPT-SESSAO.md` na raiz;
  - `CONTEXT.md` como mapa com links;
  - ADR-001 a ADR-005.
- **P01 concluído:** ADR-002 (progressão global) e ADR-003 (MIT e CC BY 4.0).
- **P02:**
  - SPEC-001 (protocolo e ping) no PR #1, com 74 testes;
  - SPEC-002 (persistência com versão de esquema e modo seguro) no PR #2, com 101 testes no total.
- **Servidor dedicado** instalado e usado para testar (`tools\start-dev-server.bat`, servidor `churchrun_dev`):
  - o mod carrega e a persistência passa no reinício (`bootCount` 1, 2, 3);
  - bug achado: o Kahlua não tem `next`. Corrigido, com testes de regressão, e o lint passou a usar o std `kahlua` (`CLAUDE.md` §6.2);
  - o link de desenvolvimento passou para `Zomboid\mods`;
  - as pastas de animação vazias deixaram o log limpo.
- **P00 concluído:** o mod aparece na lista do jogo, e o `console.txt` do cliente mostra a carga e as traduções EN, PT e PT-BR, sem erro.
- **P06 preparado:** SPEC-010 aprovada e roteiro de coleta com a janela "Teletransportar" do debug. Os pontos valem também no multiplayer, porque o mapa é o mesmo.

## Decisões tomadas

- Pelo Rodrigo:
  - ID `church_run` e namespace `ChurchRun` (ADR-004);
  - MIT e CC BY 4.0 (ADR-003);
  - repositório público, com e-mail noreply;
  - CI no GitHub até o WSL;
  - relíquia de Rosewood no Kit do Peregrino, e achada da igreja 2 em diante (GDD §1.2);
  - `CONTEXT.md` como resumo com links;
  - `PROMPT-SESSAO.md` a partir do prompt dele.
- Pela recomendação, sob a autonomia dada pelo Rodrigo (reversíveis):
  - SPEC-001, SPEC-002 e SPEC-010 aprovadas;
  - ADR-005 (caminhos Lua únicos);
  - cadeia de cidades (GDD §14 #1);
  - traduções também em PT;
  - std `kahlua` no lint;
  - link de desenvolvimento em `Zomboid\mods`;
  - servidor de teste `churchrun_dev`.

## Pendências e bloqueios

- Testes com cliente do P02, merge dos PRs e coleta de Rosewood (P06): tudo com o Rodrigo.
- VERIFICAR B42 que só o teste com cliente responde:
  - a resposta em single player por `triggerEvent`;
  - o `OnCreatePlayer` dispara depois de o servidor aceitar pedidos;
  - onde o `writeLog` grava;
  - uma Global ModData transmitida pelo cliente não é gravada.
- Multiplayer: as âncoras a 40–60 tiles precisam estar na área carregada com o grupo na igreja. Quem mede é a prova técnica P04; o plano B do GDD §12 traz as âncoras para 30–45 tiles.
- Decisões do GDD §14 que faltam: Fase 1, #5 (corpo do morto); Fase 2, #2; Fase 3, #8; Fase 5, #3, #4 e #9; Fase 6, #7; depois da 1.0, #6.
- Para specs futuras:
  - risco de farmar o Kit do Peregrino (P06a);
  - posição da relíquia escondida fora da Global ModData (SPEC-080);
  - item dado pelo servidor precisa aparecer no cliente (P06a);
  - sala de espera (SPEC-030).
- WSL para rodar os testes no próprio PC; até lá, o CI roda tudo.

## Arquivos tocados

Na `main`: todos os documentos da raiz, `design/`, `specs/` (índice, template, checklist, SPEC-001, SPEC-002, SPEC-010 e ADR-001 a ADR-005), `tools/start-dev-server.bat`, `.github/workflows/ci.yml`, configurações de ferramentas e o esqueleto `Contents/mods/church_run/`. Nos PRs #1 e #2: o código em `Contents/mods/church_run/42/media/lua/**`, `tests/**`, `.busted`, `.luacheckrc` e as specs atualizadas. Fora do repositório: o link `%USERPROFILE%\Zomboid\mods\church_run`, a config e o save do `churchrun_dev`, o Umbrella em `C:\dev\Umbrella` e a memória do projeto.
