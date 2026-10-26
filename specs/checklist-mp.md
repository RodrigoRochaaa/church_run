# Checklist manual de multiplayer

Obrigatório antes de cada release (`CLAUDE.md` §7) e para fechar uma fase (`CONTEXT.md` §6). Copie as seções para a descrição do PR, marque e anote o que falhou. Como montar o servidor e os clientes: `DEPENDENCIES.md` §5.

## Execução

- Data:
- Versão do jogo (servidor e clientes):
- Versão do mod (`modversion` no `mod.info`):
- Servidor: dedicado local / listen server
- Quem testou:

## Itens obrigatórios

A descrição completa de cada item está no `CLAUDE.md` §7.

- [ ] 1. Servidor dedicado B42 local + 2 clientes.
- [ ] 2. Os dois jogadores no mesmo cerco até a vitória; cada um recebe a recompensa uma vez.
- [ ] 3. Clique duplo e reenvio não cobram nem pagam duas vezes.
- [ ] 4. Desconectar no meio de um cerco ou de uma compra não duplica itens nem recompensas.
- [ ] 5. Reiniciar o servidor mantém o progresso.
- [ ] 6. Morte do personagem segue a regra da spec.
- [ ] 7. Comando com argumentos inválidos é recusado e logado.
- [ ] 8. Listen server (host jogando) funciona sem execução duplicada.
- [ ] 9. Log do servidor sem erros de Lua do mod.

Itens que dependem de funcionalidade ainda não feita (cerco, compra) são marcados "n/a" até a fase que os traz.

## Casos por spec

### SPEC-001 Protocolo de comandos

- [ ] CA1: cada cliente registra o `pong` com o tempo de ida e volta; o servidor registra um `ping` por username.
- [ ] CA5: cliente com versão de protocolo diferente vê a mensagem e não envia mais nada.
- [ ] CA14: no console de debug do cliente, `ping` com `nonce = "x"` gera `invalidArgs` e o comando `hack` gera `unknownCommand` no log do servidor, sem erro de Lua.
- [ ] CA15: com listen server, um `pong` por cliente e nenhum `ping` duplicado.
- [ ] CA16: em single player, o console registra o `ping` do servidor e o `pong` do cliente.

### SPEC-002 Persistência

- [ ] CA2: depois de `quit` e de ligar o servidor de novo, `bootCount` sobe 1 e `createdAtMs` não muda.
- [ ] CA10: `ModData.transmit("ChurchRun_World")` feito no cliente não muda os dados do servidor.
- [ ] CA11: morrer e criar outro personagem não muda `ChurchRun_World`.
