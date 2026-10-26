# GUIA-CLAUDE.md: como escolher o próximo passo, o que pesquisar e como avisar o Rodrigo

Para qualquer sessão do Claude (ou pessoa) que continuar o projeto depois que a arquitetura existir: repositório criado e esqueleto de pastas montado (Fase 0 do [`ROADMAP.md`](ROADMAP.md)).

O papel de quem segue este guia é **executar a ideia que já está no GDD**, na ordem do ROADMAP, registrando o dia no JOURNAL e avisando o Rodrigo. Não é redesenhar o jogo.

Este guia não repete o que já está em outro lugar (regra do [`DOCS-GUIDE.md`](DOCS-GUIDE.md)):
- Regras de código e fluxo de specs: [`CLAUDE.md`](CLAUDE.md).
- Ritual de início e fim de sessão: [`PROMPT-SESSAO.md`](PROMPT-SESSAO.md) e `CLAUDE.md` §11.
- O que o jogo é, com números e decisões: [`design/church_run_gdd.md`](design/church_run_gdd.md).
- Passos em ordem, com dependências e status: [`ROADMAP.md`](ROADMAP.md).
- O diário (onde a última sessão parou): [`JOURNAL.md`](JOURNAL.md). Ele é sobrescrito a cada sessão e o Git guarda os dias anteriores.

---

## 1. Como escolher o próximo passo

Aplique as regras em ordem. A primeira que decidir, vale.

1. **Termine o que está pela metade.** Um passo "em andamento" no ROADMAP vem antes de qualquer outro. O "Próximo passo" do JOURNAL costuma apontar para ele.
2. **Dependências primeiro.** Nunca comece um passo cujas dependências não estão "concluídas".
3. **Decisão pendente bloqueia.** Se o passo precisa de uma decisão do Rodrigo (GDD §14), pergunte uma vez, com uma recomendação, e enquanto espera pegue o próximo passo **não bloqueado**.
4. **Tirar o risco antes de construir.** Cada fase começa pelas provas técnicas dela. Uma funcionalidade marcada VERIFICAR no GDD §12 não ganha spec antes da prova.
5. **Fatia jogável antes de largura.** Um cerco funcionando de ponta a ponta em Rosewood vale mais que várias funcionalidades pela metade (`CONTEXT.md` §6).
6. **Empate:** escolha o passo que desbloqueia mais passos.
7. **Tamanho:** um passo grande por sessão. Passos pequenos da mesma spec podem ir juntos.

Se nada puder andar, escreva o bloqueio no JOURNAL, avise o Rodrigo com a pergunta exata e pare.

---

## 2. Como executar um passo

O fluxo é o do `CLAUDE.md` §2 (spec → plano → testes → implementação → verificação → spec atualizada). Três tipos de passo têm regras próprias:

- **Prova técnica (spike):** código mínimo e descartável, só para responder uma pergunta do GDD §12. Resultado em `research/AAAA-MM-DD-nome.md` com: pergunta, o que foi testado, resposta (sim, não ou parcial), evidência e impacto no GDD. Depois, atualize a linha do risco no GDD §12 e, se for zumbi, a tabela do GDD §5.4. É a única mudança no GDD que não precisa de aprovação.
- **Teste no jogo:** o Claude na nuvem **não roda o Project Zomboid**. Todo teste no jogo vira um checklist curto ("Teste no jogo") no PR, para o Rodrigo executar, ou é feito por uma sessão de Remote Control no PC dele, se ele pedir. O passo fica "aguardando teste" até o resultado chegar.
- **Dados do mapa** (coordenadas de altar, âncoras, pontos de nascimento): o Claude escreve um roteiro passo a passo para o Rodrigo coletar no modo debug, e depois transforma o resultado em `defs/`.

**Dúvida de design:** não invente. Se o GDD não cobre ou algo não funciona, escreva a proposta em "Pendências e bloqueios" do JOURNAL e pergunte ao Rodrigo, com uma recomendação.

---

## 3. O que pesquisar e onde

Pesquise só o que o passo atual precisa, e registre a fonte no relatório da prova.

| Pergunta (GDD §12) | Onde procurar primeiro | Passo |
| --- | --- | --- |
| Teleportar o jogador no MP sem o anti-cheat agir | Lua vanilla do B42 (`media/lua` da instalação, buscar "teleport"); comandos de admin; mods de teleporte B42 da Oficina | P03 |
| Gerar zumbis pelo servidor em pontos fixos e mandá-los até a igreja; raio da área carregada | Lua vanilla (ferramentas de debug de horda); mods de horda B42; teste no jogo | P04 |
| Painel fixo à esquerda e símbolos no mapa | Lua vanilla da UI e do mapa (`ISWorldMap`) | P05 |
| Quem matou cada zumbi no MP | Eventos de morte de zumbi no Lua vanilla; teste com 2 jogadores | P12 |
| Velocidade por zumbi | Como o Tank de OO troca a velocidade (ler o Lua publicado para aprender, sem copiar) | P20 |
| Tiro na cabeça e vida alta no MP | Eventos de acerto no Lua vanilla; changelog do Zomboid Forge (vida alta no MP) | P25 |
| Nomes de itens e roupas | `media/scripts/generated/items/` e `clothing.txt` da instalação B42.20 | P06, P14 |

**Regras de pesquisa:**
- Ler o código de outros mods para aprender é permitido. **Copiar** código ou assets só com licença compatível. Sem licença: só inspiração. GPL-3.0: só se o church_run virar GPL-3.0 (ADR-003).
- Não invente funções da API: isole a chamada num adaptador com `-- VERIFICAR B42` (`CLAUDE.md` §10).
- Animação e arte: só CC0, CC-BY ou feitas pelo projeto. Mixamo está vetado (GDD §5.4).

---

## 4. Fim de sessão: além do ritual do CLAUDE.md §11

1. **ROADMAP:** atualize o status de cada passo tocado.
2. **GDD:** se uma prova técnica respondeu um VERIFICAR, atualize o §12 e o §5.4.
3. **Avise o Rodrigo** (seção 5).
4. **Memória do projeto:** registre decisões novas do Rodrigo.

---

## 5. Como atualizar o Rodrigo

Ele escreve em português e lê de relance. Uma mensagem curta por sessão, no fim, neste formato:

```
Passo P04 concluído: zumbis já nascem nas âncoras de Rosewood e andam até a igreja.
Próximo: P05, painel à esquerda e ícones no mapa.
Preciso de você: rodar o checklist "Teste no jogo" do PR #12 (5 min).
```

- Comece pelo resultado. Uma linha por item.
- Só escreva "Preciso de você" se houver algo para ele fazer, com o tempo que leva.
- Decisão vai com uma recomendação, de preferência como cartão de decisão.

---

## 6. Regras que não mudam

1. O GDD manda no **o quê**, o `CLAUDE.md` no **como** e o ROADMAP no **quando**.
2. O que está como "Decidido" no GDD §1.2 não se rediscute sem o Rodrigo pedir.
3. Nada irreversível sem o Rodrigo: publicar na Oficina, mudar a licença, apagar dados salvos de jogadores.
4. Na dúvida entre fazer mais ou entregar menor, entregue menor e funcionando.
