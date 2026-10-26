# JOURNAL.md: onde paramos

> Este arquivo é **sobrescrito** ao fim de cada sessão (regra no `CLAUDE.md` §11). Ele mostra só a última sessão.
> O histórico completo fica no Git: `git log -p -- JOURNAL.md`. Por isso, ao fim da sessão, o journal novo é commitado.

**Data:** 26/10/2026
**Sessão:** P02: SPEC-001 e SPEC-002 aprovadas e implementadas, com a autonomia dada pelo Rodrigo
**Fase atual:** Fase 0 (Fundação), em andamento. No `ROADMAP.md`: P00 aguardando teste, P01 concluído, P02 aguardando teste (PRs #1 e #2).

## Próximo passo

1. **P00 (Rodrigo):** abrir o jogo e conferir que "Church Run" aparece na lista de mods sem erro no `%USERPROFILE%\Zomboid\console.txt`; instalar o Project Zomboid Dedicated Server (Steam → Biblioteca → Ferramentas).
2. **P02 (Rodrigo):** rodar o checklist "Teste no jogo" do PR #1 e depois o do PR #2 (cerca de 10 min cada). Se passar: mesclar o #1 e depois o #2 (a base do #2 muda sozinha para a `main`), escrever "42.21.0" em "Versão mínima do jogo testada" nas duas specs e marcar o P02 como concluído no ROADMAP. Se falhar: anotar no PR o que apareceu no `console.txt`.
3. **Claude, assim que o P00 fechar:** escrever a SPEC-010 (igrejas e âncoras) e o roteiro de coleta do P06 para Rosewood (`GUIA-CLAUDE.md` §2, "Dados do mapa"). Com o P02 concluído, ficam desbloqueadas as provas técnicas P03, P04 e P05.

## O que foi feito

- SPEC-001 e SPEC-002 aprovadas pelas respostas recomendadas (ver "Decisões tomadas").
- ADR-005: o código do cliente fica em `ChurchRun/Client/` e o do servidor em `ChurchRun/Server/`. Motivo: o `require` do jogo procura o nome nas três pastas, e o vanilla 42.21.0 não repete nenhum caminho entre elas. `CLAUDE.md`, `CONTEXT.md` e SPEC-002 ajustados.
- [PR #1](https://github.com/RodrigoRochaaa/church_run/pull/1), SPEC-001 (branch `spec-001-protocolo`):
  - catálogo e validador de esquema; roteador na ordem do R4, com rate limit por jogador e comando e log de auditoria limitado a 10 linhas por minuto;
  - ping no `OnCreatePlayer`, aviso de versão diferente (`ISModalDialog`, traduções EN e PT-BR) e entrega em single player por `triggerEvent`;
  - adaptadores, ports e os dois `Main.lua`; 73 testes.
- [PR #2](https://github.com/RodrigoRochaaa/church_run/pull/2), SPEC-002 (branch `spec-002-persistencia`, em cima do #1):
  - `ChurchRun_World` v1 (`createdAtMs`, `bootCount`), migrações tudo-ou-nada com backup e modo seguro;
  - trava do roteador: sem os dados, só o ping passa; 98 testes no total.
- CI verde nos dois PRs, com o luacheck sem avisos em 40 arquivos. Isso resolveu o VERIFICAR dos globs do `.luacheckrc`: `**` casa zero pastas.
- API do 42.21.0 conferida no Lua vanilla, no Umbrella e nas classes do jogo:
  - `ISModalDialog:new(x, y, w, h, texto, simNao)`;
  - `getText(chave, a, b)` com `%1`/`%2`;
  - `OnCreatePlayer(playerIndex, player)`;
  - `args` chega `nil` quando a tabela está vazia;
  - mods publicam o próprio `Translate/EN/UI.json`.

## Decisões tomadas

Todas pelas recomendações, sob a autonomia dada pelo Rodrigo em 26/10/2026; podem ser revistas quando ele voltar.

- SPEC-001: single player suportado (R16); limites de comando ajustáveis pelo admin ficam para uma spec futura.
- SPEC-002: backup antes de migrar mantido; single player com a mesma persistência (R12).
- GDD §13: a primeira fatia jogável segue o ROADMAP, e a carteira entra na Fase 2 (GUIA §6.1).
- ADR-005 (caminhos Lua únicos).
- Mensagens de erro de desenvolvedor em inglês ASCII, porque não se sabe com que codificação o Kahlua lê o código; comentários continuam em português.
- O P02 começou com o P00 ainda "aguardando teste". O que falta no P00 é só o teste no jogo, que não afeta o código Lua puro. Para cumprir a regra de dependências do GUIA, os PRs só devem ser mesclados depois desse teste.

## Pendências e bloqueios

- Testes no jogo do P00 e do P02 (Rodrigo). Nada é mesclado sem eles (`CLAUDE.md` §8: PR que toca rede ou dados precisa do checklist de MP).
- VERIFICAR B42, a confirmar nesses testes:
  - em single player, a resposta volta por `triggerEvent`;
  - o `OnCreatePlayer` dispara quando o servidor já aceita pedidos;
  - onde o `writeLog` grava;
  - o `OnInitGlobalModData` dispara antes do primeiro jogador;
  - uma Global ModData transmitida pelo cliente não é gravada pelo servidor.
- Decisões do GDD §14 por fase: Fase 1, #1 (cadeia) e #5 (corpo do morto); Fase 2, #2 (carteira); Fase 3, #8 (os 30 buffs); Fase 5, #3, #4 e #9; Fase 6, #7; depois da 1.0, #6. Sob a autonomia, cada uma recebe a proposta do GDD quando a fase dela chegar, a menos que o Rodrigo diga outra coisa.
- Para as specs futuras:
  - risco de farmar o Kit do Peregrino morrendo de propósito (spec do P06a);
  - a posição da relíquia escondida não pode ficar na Global ModData, que qualquer cliente lê (SPEC-080);
  - item dado pelo servidor precisa aparecer no cliente sem sincronização extra (VERIFICAR do P06a).
- WSL antes de rodar os testes no próprio PC; até lá, o CI roda tudo.

## Arquivos tocados

Na `main`: `specs/001-protocolo-comandos.md`, `specs/002-persistencia.md`, `specs/README.md`, `specs/checklist-mp.md`, `specs/decisions/ADR-005-caminhos-lua-unicos.md`, `CLAUDE.md`, `CONTEXT.md`, `DOCS-GUIDE.md`, `design/church_run_gdd.md`, `ROADMAP.md`, `JOURNAL.md`. Nos PRs: `Contents/mods/church_run/42/media/lua/**`, `tests/**`, `.busted`, `.luacheckrc`, `DEPENDENCIES.md`, `CHANGELOG.md` e as duas specs.
