# ADR-001: servidor autoritativo

- **Status:** aceita
- **Data:** 25/10/2026 (registrada no repositório em 26/10/2026)
- **Origem:** [plano de arquitetura](https://claude.ai/artifact/TbL7fUBqqyNAfFwZNwhjhQ), seções "Fluxo multiplayer e autoridade do servidor" e "Cuidados para o mod rodar sem problemas"

## Contexto

No multiplayer do Project Zomboid, qualquer cliente pode estar modificado e mandar qualquer comando com quaisquer valores. Uma mudança feita só no cliente dessincroniza em silêncio. O mod paga recompensas (moedas, itens, buffs, spawns liberados), então trapaça e pagamento duplo são os riscos principais.

## Decisão

- Todo estado do mod (cerco, progresso, compras, buffs, recompensas) é decidido e gravado só no servidor, em `lua/server`.
- O cliente manda intenções por `sendClientCommand`, num único módulo de comandos (`ChurchRun`), e mostra o que o servidor responde. A UI só muda com a resposta do servidor, nunca de forma otimista.
- O servidor valida todo pedido antes de qualquer lógica: esquema dos argumentos, rate limit, identidade pelo evento e revalidação no mundo (inventário, distância, estado do cerco). Pagamentos são idempotentes e tudo-ou-nada.
- O servidor manda ao jogador o estado completo dele, nunca deltas que dependam de mensagens anteriores.

As regras detalhadas estão no `CLAUDE.md` §1 e §4; o protocolo, na [SPEC-001](../001-protocolo-comandos.md).

## Consequências

- Toda funcionalidade tem dois lados (pedido no cliente, caso de uso no servidor) e uma seção de segurança na spec.
- A interface espera uma ida e volta ao servidor; feedback imediato só visual (ex.: botão desativado), sem prever o resultado.
- A lógica do servidor fica testável fora do jogo, com ports falsos.
- Listen server usa o mesmo caminho (comando → servidor), sem atalhos com `isClient()`/`isServer()`.
