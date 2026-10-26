# ADR-002: progressão global do servidor

- **Status:** aceita
- **Data:** 26/10/2026
- **Origem:** [viabilidade](https://claude.ai/artifact/WojQe1M1D7Di5SrskpNkZT), decisão D2 ("Progresso do servidor inteiro ou por jogador?"), respondida pelo Rodrigo em 26/10/2026

## Contexto

A campanha tem igrejas em ordem (proposta: Rosewood → Riverside → West Point → Muldraugh → Louisville). Cada conquista libera o próximo ponto de nascimento, moedas e buffs. Era preciso escolher se esse avanço é do servidor inteiro ou de cada jogador.

## Decisão

O progresso da campanha é **um só para o servidor inteiro**. Igrejas conquistadas, igreja atual e spawn liberado ficam no estado global do servidor (`ChurchRun_World`, ver [SPEC-002](../002-persistencia.md)) e valem para todos os jogadores, inclusive para quem entra depois.

## Consequências

- Quem entra depois de uma conquista já nasce no spawn mais recente e vê as igrejas vencidas no mapa (SPEC-011, SPEC-061).
- A recompensa da vitória é paga uma vez a cada jogador vivo no fim do cerco (`CONTEXT.md` §3). Quem entra depois não recebe a recompensa de conquistas passadas.
- Buffs continuam por personagem e se perdem na morte (SPEC-050). Só a campanha é global.
- Continuam abertas na D2: o que acontece com o corpo do morto, onde o morto espera e o que acontece se metade do grupo morrer (SPEC-030).
