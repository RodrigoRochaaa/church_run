# PROMPT-SESSAO.md: o prompt de início de sessão

Cole o bloco abaixo no começo de cada sessão do Claude; uma pessoa pode segui-lo como roteiro. Ele junta o ritual de início (ler e confirmar), a execução e o fim de sessão. As regras ficam nos arquivos que ele cita: este arquivo só dá a ordem.

```text
Você vai trabalhar no mod church_run de Project Zomboid (Build 42, multiplayer, Lua puro, servidor autoritativo). Responda em português.

FASE 1: PEGAR O CONTEXTO (só leitura, não altere nada ainda)
Leia nesta ordem:
1. JOURNAL.md: onde a última sessão parou, o próximo passo, pendências.
2. CONTEXT.md: o que é o mod, a arquitetura, as pastas e as fases.
3. CLAUDE.md: as regras obrigatórias. Elas valem acima de qualquer preferência sua.
4. GUIA-CLAUDE.md: como escolher o próximo passo, o que pesquisar e como me avisar.
5. ROADMAP.md: os passos de cada fase, com dependências e status.
6. design/church_run_gdd.md: o que o jogo é. Se o passo tocar em lojas ou buffs, também design/lojas.md ou design/buffs.md.
7. DOCS-GUIDE.md: qual arquivo guarda cada tipo de informação.
8. Se o passo for de código: specs/README.md, a spec do passo e as ADRs em specs/decisions/ ligadas a ela.
9. Só se o passo envolver ambiente, ferramentas ou testes: DEPENDENCIES.md.

Depois de ler, me responda em no máximo 10 linhas:
- fase atual, passo do ROADMAP e próximo passo segundo o journal;
- o passo que você vai executar (pelas regras do GUIA-CLAUDE.md §1) e as specs/regras que se aplicam;
- dúvidas, contradições entre os arquivos ou decisões que dependem de mim.
Pare e espere meu "ok" antes da fase 2.

FASE 2: EXECUTAR
- Siga o fluxo do CLAUDE.md §2: spec → plano de tarefas → testes → implementação → verificação → atualização da spec.
- Sem spec aprovada, não escreva código: proponha a spec primeiro.
- Prova técnica, teste no jogo e dados do mapa seguem o GUIA-CLAUDE.md §2.
- Chamadas à API do jogo só em adapters/ e nos Main.lua, com a exceção da UI do CLAUDE.md §3.4. Se não tiver certeza de que um método existe no B42, marque com -- VERIFICAR B42.
- Questione minhas escolhas quando houver um caminho melhor, e diga o que é viável.

FASE 3: ENCERRAR (quando eu disser "encerrar sessão" ou o passo acabar)
1. Sobrescreva o JOURNAL.md inteiro com o modelo do CLAUDE.md §11. "Próximo passo" deve ser concreto (arquivo, spec, regra).
2. Atualize no ROADMAP.md o status de cada passo tocado.
3. Decisão de arquitetura nova vira ADR. Decisão minha de design vai para o GDD §1.2 e para a memória do projeto. Prova técnica que respondeu um VERIFICAR atualiza o GDD §12 (e o §5.4, se for zumbi). Mudança visível ao jogador vai para o CHANGELOG.md. Fase concluída é marcada no CONTEXT.md §6.
4. Faça o commit do trabalho junto com o journal.
5. Me avise no formato do GUIA-CLAUDE.md §5 (resultado, próximo passo, "Preciso de você") e liste as regras da spec cobertas e o que ficou para teste manual.

TAREFA DESTA SESSÃO: seguir o "Próximo passo" do JOURNAL.md, escolhido pelas regras do GUIA-CLAUDE.md §1.
```
