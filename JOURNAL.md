# JOURNAL.md: onde paramos

> Este arquivo é **sobrescrito** ao fim de cada sessão (regra no `CLAUDE.md` §11). Ele mostra só a última sessão.
> O histórico completo fica no Git: `git log -p -- JOURNAL.md`. Por isso, ao fim da sessão, o journal novo é commitado.

**Data:** 26/10/2026
**Sessão:** P06 preparado: SPEC-010 (igrejas e âncoras) e roteiro de coleta no modo debug
**Fase atual:** Fase 0 (Fundação), em andamento, e preparação da Fase 1. No `ROADMAP.md`: P00 e P02 aguardando teste com cliente (PRs #1 e #2 prontos para mesclar, CI verde); P06 aguardando a coleta do Rodrigo.

## Próximo passo

1. **Rodrigo:** o repositório está na branch `spec-002-persistencia`, que inclui os dois PRs e é a que o jogo lê pelo link `Zomboid\mods\church_run`. Numa sentada só (cerca de 45 min):
   - abrir o jogo com `-debug` e ver "Church Run" na lista de mods. Isso fecha o P00;
   - seguir os checklists "Teste no jogo" do [PR #1](https://github.com/RodrigoRochaaa/church_run/pull/1) e do [PR #2](https://github.com/RodrigoRochaaa/church_run/pull/2) e, se passar, mesclar o #1 e depois o #2;
   - coletar os pontos de Rosewood pelo [`design/coleta-mapa.md`](design/coleta-mapa.md) e colar a lista no chat.
2. **Claude, com a lista de Rosewood:** conferir as distâncias e abrir o PR da SPEC-010, com `shared/ChurchRun/defs/churches.lua`, a conferência pura em `shared/ChurchRun/domain/churches/` e os testes dos CA1 a CA6. Com o P02 mesclado, ficam desbloqueadas as provas técnicas P03, P04 e P05.

## O que foi feito

- **SPEC-010 aprovada** (pela recomendação, sob a autonomia):
  - pontos de cada igreja (altar, porta, nascimento, chegada do teleporte, 6 a 10 âncoras a 40–60 tiles, sala de espera opcional);
  - ordem da campanha;
  - conferência pura na carga: uma igreja com erro fica desativada, e as âncoras nunca vão para o cliente.
- **Roteiro de coleta** em `design/coleta-mapa.md`. Usa a janela "Teletransportar" do debug (Debug → Principal → Teletransportar → Copiar), conferida no Lua vanilla do 42.21.0, com os nomes em PT, o idioma do jogo do Rodrigo. O console de Lua do B42 não foi achado no Lua vanilla, então o roteiro não depende dele.
- **GDD:** cadeia de cidades decidida pela proposta do §2 (§1.2 e §14 #1).
- **Traduções também em PT:** o jogo do Rodrigo está em PT, e o `language.json` do PT não declara outro idioma de base, então sem o arquivo a mensagem sairia em inglês. Regra no `CLAUDE.md` §6.1; o `PT/UI.json` entrou no PR #1.
- `main` levada aos dois PRs, sem conflito pendente. CI verde: #1 com 74 testes, #2 com 101.

## Decisões tomadas

Pela autonomia dada pelo Rodrigo em 26/10/2026, todas reversíveis:

- SPEC-010 aprovada como escrita. O ponto do altar é o quadrado em frente a ele (onde o jogador fica), porque o personagem não pisa no móvel e o debug não mostra a coordenada de um objeto.
- Cadeia Rosewood → March Ridge → Muldraugh → West Point → Louisville (GDD §14 #1).
- Traduções no mínimo em EN, PT-BR e PT.

## Pendências e bloqueios

- Teste com cliente (P00 e P02), merge dos PRs e coleta de Rosewood (P06): tudo com o Rodrigo.
- VERIFICAR B42 que só o teste com cliente responde:
  - a resposta em single player por `triggerEvent`;
  - o `OnCreatePlayer` dispara depois de o servidor aceitar pedidos;
  - onde o `writeLog` grava;
  - uma Global ModData transmitida pelo cliente não é gravada.
- Decisões do GDD §14 que ainda faltam: Fase 1, #5 (corpo do morto); Fase 2, #2; Fase 3, #8; Fase 5, #3, #4 e #9; Fase 6, #7; depois da 1.0, #6.
- Para specs futuras:
  - risco de farmar o Kit do Peregrino (P06a);
  - posição da relíquia escondida fora da Global ModData (SPEC-080);
  - item dado pelo servidor precisa aparecer no cliente (P06a);
  - sala de espera (SPEC-030).
- WSL para rodar os testes no próprio PC; até lá, o CI roda tudo.

## Arquivos tocados

Na `main`: `specs/010-igrejas.md`, `specs/README.md`, `design/coleta-mapa.md`, `design/church_run_gdd.md`, `CONTEXT.md`, `DOCS-GUIDE.md`, `ROADMAP.md`, `CLAUDE.md`, `JOURNAL.md`. No PR #1: `Contents/mods/church_run/42/media/lua/shared/Translate/PT/UI.json` e `specs/001-protocolo-comandos.md`. Merges da `main` nos dois PRs.
