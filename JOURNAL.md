# JOURNAL.md: onde paramos

> Este arquivo é **sobrescrito** ao fim de cada sessão (regra no `CLAUDE.md` §11). Ele mostra só a última sessão.
> O histórico completo fica no Git: `git log -p -- JOURNAL.md`. Por isso, ao fim da sessão, o journal novo é commitado.

**Data:** 26/10/2026
**Sessão:** Documentos novos (GDD, ROADMAP, GUIA) organizados e alinhados
**Fase atual:** Fase 0 (Fundação), em andamento. No `ROADMAP.md`: P00 aguardando teste, P01 concluído, P02 aguardando Rodrigo.

## Próximo passo

1. **P00 (Rodrigo):** abrir o jogo e conferir que "Church Run" aparece na lista de mods sem erro no `%USERPROFILE%\Zomboid\console.txt`; instalar o Project Zomboid Dedicated Server (Steam → Biblioteca → Ferramentas). Isso fecha o P00.
2. **P02 (Rodrigo):** aprovar ou ajustar `specs/001-protocolo-comandos.md` e `specs/002-persistencia.md`, respondendo às "Questões em aberto" de cada uma.
3. **Claude, assim que o P00 fechar:** escrever o roteiro de coleta do P06 (altar, raio, 6 a 10 âncoras e ponto de nascimento de Rosewood, SPEC-010), pelo `GUIA-CLAUDE.md` §2 "Dados do mapa". É o primeiro passo desbloqueado enquanto as specs esperam aprovação.

## O que foi feito

- Pasta `design/` criada: GDD v0.2 (`design/church_run_gdd.md`), `design/lojas.md` (a v0.1 ficou no histórico do Git e a v0.2 entrou por cima) e `design/buffs.md`. `GUIA-CLAUDE.md` e `ROADMAP.md` entraram no Git como chegaram.
- `PROMPT-SESSAO.md` criado a partir do prompt de sessão do Rodrigo, com a ordem de leitura nova: JOURNAL → CONTEXT → CLAUDE → GUIA → ROADMAP → GDD → DOCS-GUIDE → specs.
- GDD §1.2 ganhou as decisões de 26/10/2026 (ID, licença, Kit do Peregrino com a relíquia de Rosewood, relíquia achada da igreja 2 em diante), com ajustes no §4.1, §7.1, §11.1 e §14.9.
- ROADMAP: status de P00, P01 e P02 atualizados; novo P06a (Kit do Peregrino e relíquia de Rosewood, depende do P02); o P07 passa a depender do P06a; o P24 traz a relíquia escondida como decidida.
- `CONTEXT.md` virou um mapa com links para o GDD e o ROADMAP, sem repetir números de design. `DOCS-GUIDE.md` ganhou o GDD, os anexos, o ROADMAP, o GUIA, o PROMPT-SESSAO e a pasta `research/`, a numeração de specs do GDD §13 e a regra de quem manda em quê. O `CLAUDE.md` aponta para o GDD, o ROADMAP e o GUIA, e a §11 inclui o fim de sessão do GUIA §4.
- Correções: ADR-003 (SPEC-072 → SPEC-079, só a referência), teleporte em `design/lojas.md` (→ GDD §2.2), reroll em `design/buffs.md` (1 grátis decidido, extra a 15 × N) e links novos no `README.md`.
- Verificação: script conferiu 70 links locais dos `.md`, 0 quebrados (o mesmo script acusa links quebrados num teste negativo).
- Memória do ambiente copiada para a pasta de memória do projeto, porque a raiz do Git mudou para a pasta do projeto.

## Decisões tomadas

- Relíquia já na Fase 1: o Kit do Peregrino vem numa mochila básica e traz a relíquia de Rosewood enquanto ela não for conquistada; da igreja 2 em diante a relíquia é achada (GDD §1.2).
- `PROMPT-SESSAO.md` feito a partir do prompt do Rodrigo; v0.1 das lojas guardada só no histórico do Git; `CONTEXT.md` como resumo com links para o GDD.
- O P06a depende do P02, e não do P03: o kit precisa do servidor saber se Rosewood foi conquistada, não do teleporte.

## Pendências e bloqueios

- P00 e P02 esperam o Rodrigo (ver "Próximo passo").
- Decisões do GDD §14 por fase: Fase 1, #1 (cadeia) e #5 (corpo do morto); Fase 2, #2 (carteira ou moeda física); Fase 3, #8 (os 30 buffs); Fase 5, #3 (teleporte), #4 (descontos) e #9 (missões); Fase 6, #7 (o Bispo); depois da 1.0, #6 (contra-ataques).
- O GDD §13 põe a carteira na primeira fatia jogável, mas o ROADMAP põe as moedas na Fase 2 (P13). Pelo GUIA §6.1 o ROADMAP manda no "quando", então vale a Fase 2, e as 30 moedas do kit entram com o P13. Confirmar com o Rodrigo ou ajustar o GDD §13.
- Risco do kit: dá para farmar o kit morrendo de propósito. Mitigação proposta para a spec do P06a: esvaziar o corpo (decisão #5) e um kit por personagem.
- Segredo da relíquia escondida (igrejas 2 a 5): qualquer cliente pode ler a Global ModData (SPEC-002, Segurança), então a posição da relíquia não pode ficar lá. Resolver na SPEC-080.
- VERIFICAR B42 do P06a: item dado pelo servidor aparece no cliente sem sincronização extra (plano de arquitetura, "Recompensas").
- WSL antes da primeira spec com código (o CI cobre até lá); globs do `.luacheckrc` a conferir no primeiro PR com código.

## Arquivos tocados

`design/church_run_gdd.md`, `design/lojas.md`, `design/buffs.md`, `GUIA-CLAUDE.md`, `ROADMAP.md`, `PROMPT-SESSAO.md`, `CONTEXT.md`, `DOCS-GUIDE.md`, `CLAUDE.md`, `README.md`, `specs/decisions/ADR-003-licenca.md`, `JOURNAL.md`
