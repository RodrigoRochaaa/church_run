# SPEC-001 Protocolo de comandos

- **Status:** implementada em 26/10/2026 (branch `spec-001-protocolo`), aguardando o teste no jogo do PR. Aprovada no mesmo dia com as respostas recomendadas às questões em aberto (single player suportado; limites ajustáveis numa spec futura), sob a autonomia dada pelo Rodrigo
- **Versão mínima do jogo testada:** — (API conferida no código do 42.21.0 em 26/10/2026; nada testado no jogo ainda)
- **Fase:** 0 (`CONTEXT.md` §6)
- **ADRs ligadas:** [ADR-001](decisions/ADR-001-servidor-autoritativo.md), [ADR-004](decisions/ADR-004-id-e-namespace.md)
- **Depende de:** —

## Objetivo

Cliente e servidor precisam de um canal único e seguro para pedidos e respostas. Esta spec define o módulo de comandos `ChurchRun`, o catálogo de comandos com esquemas, a validação no servidor antes de qualquer lógica, o rate limit, o log de recusas e a checagem de versão do protocolo. Define também um `ping` que prova que o mod carregou nos dois lados (Fase 0, etapa 1 do plano de arquitetura).

## Fora do escopo

- Comandos de jogo (cerco, loja, buffs): cada spec acrescenta os seus ao catálogo, seguindo as regras daqui.
- Comandos de admin e checagem de nível de acesso: chegam com a primeira spec que tiver um comando de admin. No B42.21 o vanilla usa `player:getRole():hasCapability(Capability.X)`.
- Persistência (SPEC-002) e o comando `sync` de estado do jogador, que chega com a primeira spec que tiver estado de jogador.
- Limites configuráveis pelo admin do servidor (Sandbox Options).

## Comportamento

- **R1. Canal único.** Todo pedido do mod usa `sendClientCommand(player, "ChurchRun", comando, args)`. Toda resposta usa `sendServerCommand(player, "ChurchRun", comando, args)` (um jogador) ou `sendServerCommand("ChurchRun", comando, args)` (todos). Mensagens de outros módulos são de outros mods ou do jogo: o roteador as ignora sem log.
- **R2. Catálogo.** Todo comando está em `shared/ChurchRun/protocol/commands.lua`, com nome (`camelCase`, até 32 caracteres), direção (`toServer` ou `toClient`) e esquema dos argumentos. Todo comando `toServer` declara também o rate limit (R7). Comando fora do catálogo não existe.
- **R3. Esquema.** Cada campo declara tipo e limites:
  - `string`: `maxLen` obrigatório (até 256), `minLen` opcional;
  - `integer`: `min` e `max` obrigatórios; recusa fração, NaN e infinito;
  - `number`: `min` e `max` obrigatórios; recusa NaN e infinito;
  - `boolean`;
  - `enum`: lista fechada de strings.
  
  Todo campo é obrigatório, a menos que marque `optional = true`. Tabelas aninhadas não são aceitas nesta versão; a primeira spec que precisar define o tipo. O nome `pv` é reservado (R5).
- **R4. Validação antes de qualquer lógica**, nesta ordem, parando na primeira falha:
  1. módulo é `ChurchRun` (senão, R1);
  2. o comando existe no catálogo e é `toServer` (senão, log `unknownCommand` e nenhuma resposta);
  3. há ficha no balde do jogador para esse comando (senão, R7);
  4. `pv` é igual à versão do servidor (senão, R5);
  5. os argumentos batem com o esquema: nenhum campo desconhecido, nenhum obrigatório ausente, tipo e faixa certos (senão, `rejected` com `invalidArgs`).
  
  Só depois o handler do caso de uso roda. Um campo desconhecido encerra a validação na hora, sem percorrer o resto da tabela. A SPEC-002 acrescenta um passo depois do 5: com a persistência em modo seguro, só o `ping` é atendido.
- **R5. Versão do protocolo.** `shared/ChurchRun/protocol/version.lua` define `PROTOCOL_VERSION`, inteiro que começa em 1. Todo pedido leva `pv` nos argumentos, e quem acrescenta é o cliente de rede (`net/`), nunca a UI. `pv` ausente, que não seja inteiro ou diferente da versão do servidor → o servidor responde `versionMismatch` e não executa o pedido. Ao receber `versionMismatch`, o cliente mostra uma janela com uma mensagem traduzida (EN e PT-BR) e para de enviar pedidos até o jogo ser reiniciado. A versão sobe quando um comando muda de forma incompatível, o que é versão major do mod (`CLAUDE.md` §8). Com `DoLuaChecksum=true` (padrão do servidor), um cliente com Lua diferente nem entra; a checagem cobre servidores com o checksum desligado.
- **R6. Identidade.** Quem pede é sempre o `player` recebido em `OnClientCommand`, identificado pelo username. Argumentos nunca dizem quem pede. Se o jogo não informar o username, o roteador usa `?` no log e no balde.
- **R7. Rate limit por jogador e por comando** (balde de fichas). Cada comando `toServer` declara `burst` (fichas máximas) e `perSecond` (reposição). O balde começa cheio. Pedido sem ficha é descartado: log `rateLimited` e nenhuma resposta, para não devolver uma mensagem a cada pedido de spam. O relógio é o real (`getTimestampMs()`, pelo port `Clock`), não o do jogo.
- **R8. Log de recusas.** Toda recusa gera uma linha de auditoria no servidor com username, comando, motivo e horário, sem outros dados pessoais. Cada jogador grava no máximo 10 linhas de recusa por minuto. As excedentes são contadas, e a próxima linha registrada sobre o jogador informa quantas foram suprimidas; se ele parar de mandar pedidos, a varredura do R14 registra a contagem. Texto vindo do cliente (ex.: nome de comando desconhecido) vai para o log com no máximo 32 caracteres e sem quebras de linha nem caracteres de controle, para ninguém forjar linhas de log.
- **R9. Resposta a recusas.** Pedido recusado por `invalidArgs` ou por erro interno (R10) recebe `rejected { command, reason, field? }`, para o cliente mostrar a falha em vez de esperar para sempre. Comando desconhecido e pedido sem ficha não recebem resposta.
- **R10. Erro não derruba o servidor.** O handler roda em `pcall`. Se der erro: log com o comando e a mensagem, resposta `rejected` com `internalError`, e o roteador segue atendendo os pedidos seguintes.
- **R11. Ping.** `ping { pv, nonce }` → `pong { nonce }`. O cliente manda um `ping` quando o personagem local é criado (`OnCreatePlayer`, índice 0) e registra no console do cliente o tempo de ida e volta. O servidor registra cada ping recebido com o username. É o teste de "mod carregado nos dois lados" da Fase 0.
- **R12. Validação também no cliente, só como ajuda.** `net/` valida o pedido com o mesmo esquema antes de enviar. Se falhar, registra o erro no console do cliente e não envia. O servidor valida de novo sempre (R4).
- **R13. Respostas também têm esquema.** O cliente descarta, com log local, mensagem `toClient` que não bate com o esquema. `pong` com `nonce` que o cliente não mandou é ignorado.
- **R14. Limpeza da memória.** Baldes de rate limit e contadores de log vivem só na memória do servidor e somem num reinício. No máximo uma vez por minuto, disparada pelo próprio tráfego de comandos, uma varredura remove baldes cheios (jogador parado ou que saiu) e contadores de janelas vencidas. Assim a limpeza não depende de evento de desconexão, que o B42.21 não tem no servidor (R15).
- **R15. Nota de API (26/10/2026).** Na lista de eventos do 42.21.0 (`LuaEventManager`) não há evento de desconexão de jogador no servidor; só `OnDisconnect`, que roda no cliente. Specs que precisarem detectar a saída de um jogador usam o adaptador `Players` (VERIFICAR B42 a melhor forma: comparar `getOnlinePlayers()` periodicamente).
- **R16. Single player.** O caminho é o mesmo do multiplayer, com uma diferença no adaptador de rede do servidor. Em single player, `sendClientCommand` chega ao `OnClientCommand` local, mas `sendServerCommand` não volta ao cliente. Por isso, quando o jogo não é cliente nem servidor de multiplayer (`isClient()` e `isServer()` falsos), o adaptador entrega a resposta com `triggerEvent("OnServerCommand", módulo, comando, args)`. Evidência: no 42.21.0, a classe que implementa esses globais (`LuaManager$GlobalObject`) cita `OnClientCommand` e não cita `OnServerCommand`. VERIFICAR B42 em jogo.

## Contrato

### Comandos de rede

| Comando | Direção | Argumentos (tipo e limites) | Rate limit | Resposta |
|---|---|---|---|---|
| `ping` | toServer | `pv`: integer 1–1000; `nonce`: integer 0–2147483647 | burst 3, `perSecond` 0,2 (1 a cada 5 s) | `pong` ou `versionMismatch` |
| `pong` | toClient | `nonce`: integer 0–2147483647 | — | — |
| `versionMismatch` | toClient | `serverVersion`: integer 1–1000 | — | — |
| `rejected` | toClient | `command`: string 1–32; `reason`: enum `invalidArgs`, `internalError`; `field`: string 1–32, opcional | — | — |

Novos motivos de `rejected` entram pela spec que os usa (ex.: SPEC-002 acrescenta `serverDataUnavailable`).

### Textos para o jogador

| Chave | Arquivo | EN | PT-BR |
|---|---|---|---|
| `UI_ChurchRun_VersionMismatch` | `shared/Translate/EN/UI.json` e `PTBR/UI.json` | "Church Run: this server uses protocol version %1 and your mod uses %2. Update the mod and restart the game." | "Church Run: este servidor usa a versão %1 do protocolo e o seu mod usa a %2. Atualize o mod e reinicie o jogo." |

### Log

Formato de linha: `[ChurchRun] <NÍVEL> <evento> chave=valor ...`, com os campos em ordem alfabética e cada valor limpo e cortado em 64 caracteres.

| Lado | Eventos |
|---|---|
| Servidor, auditoria (R8) | `unknownCommand`, `rateLimited`, `versionMismatch`, `invalidArgs`, `refusalsSuppressed` |
| Servidor, demais | `serverReady`, `serverDisabled`, `ping`, `handlerError`, `routerError` |
| Cliente | `pong`, `unexpectedPong`, `rejected`, `versionMismatch`, `sendBlocked`, `unknownCommand`, `invalidArgs`, `unknownServerCommand`, `invalidServerArgs`, `clientError`, `clientDisabled` |

### Dados salvos

Nenhum. Baldes e contadores ficam só na memória (R14).

### Eventos e API do jogo usados

| Uso | API | Conferido |
|---|---|---|
| Enviar pedido | `sendClientCommand(player, module, command, args)` | Umbrella 42.21.0 e Lua vanilla do 42.21.0 |
| Receber pedido no servidor | `Events.OnClientCommand`, callback `(module, command, player, args)`; `args` chega `nil` se a tabela estava vazia | Umbrella 42.21.0 |
| Responder | `sendServerCommand(player, module, command, args)` e `sendServerCommand(module, command, args)` | Umbrella 42.21.0 e Lua vanilla do 42.21.0 |
| Receber resposta no cliente | `Events.OnServerCommand`, callback `(module, command, args)` | Umbrella 42.21.0 |
| Ping inicial | `Events.OnCreatePlayer`, callback `(playerIndex, player)` | Umbrella 42.21.0; VERIFICAR B42 se dispara depois que o servidor já aceita comandos do jogador |
| Identidade | `player:getUsername()` | Lua vanilla do 42.21.0 |
| Relógio real | `getTimestampMs()` | Umbrella 42.21.0 |
| Log de auditoria | `print` e `writeLog(loggerName, logs)` | Umbrella 42.21.0; VERIFICAR B42 onde o `writeLog` grava o arquivo |
| Texto traduzido | `getText(chave, ...)`; arquivos JSON em `shared/Translate/<idioma>/` | Umbrella 42.21.0; formato JSON e pasta `PTBR` conferidos nos arquivos do 42.21.0. VERIFICAR B42 a passagem de parâmetros `%1`/`%2` e se o `UI.json` do mod é somado ao do jogo |
| Janela de aviso | `ISModalDialog:new(x, y, w, h, texto, simNao)`, depois `initialise()` e `addToUIManager()` | Lua vanilla do 42.21.0 (`ISModalDialog.lua`, `BrushToolManager.lua`) |
| Single player: detectar e entregar a resposta localmente (R16) | `isClient()`, `isServer()` e `triggerEvent("OnServerCommand", módulo, comando, args)` | Umbrella 42.21.0; `triggerEvent` é usado pelo vanilla. A entrega em SP é dedução das classes do 42.21.0: VERIFICAR B42 |

## Segurança

| O que um cliente malicioso tenta | Como o servidor recusa |
|---|---|
| Comando inexistente, ou de direção errada (ex.: mandar `pong`) | R4.2: ignorado, com log limitado (R8) |
| Campo a mais ou a menos, tipo errado, string enorme, número fora da faixa, NaN, infinito | R4.5: `rejected` com `invalidArgs`; o handler não roda |
| Tabela com milhares de chaves ou aninhada | R3/R4: tabela aninhada não existe no esquema; a validação para no primeiro campo desconhecido |
| Spam de pedidos, válidos ou não | R7: balde por jogador e por comando, conferido antes da validação; R8: log limitado a 10 linhas por minuto por jogador |
| Forjar linhas no log com quebras de linha no nome do comando | R8: texto do cliente é cortado em 32 caracteres e limpo de quebras e caracteres de controle |
| Fingir ser outro jogador | R6: a identidade vem do evento |
| Cliente com outra versão do protocolo (servidor sem checksum de Lua) | R5: `versionMismatch`; nada executa |
| Provocar erro de Lua no servidor | R10: `pcall`, log e `internalError`; o servidor segue |
| Encher a memória do servidor com baldes | R14: baldes cheios são removidos na varredura |

## Critérios de aceite

- **CA1** (R1, R11). Dado um servidor dedicado com o mod e dois clientes, quando cada cliente entra, então cada um registra o `pong` com o tempo de ida e volta, e o servidor registra dois `ping`, um por username. Checklist MP.
- **CA2** (R2, R4.2, R8). Dado o roteador com o catálogo, quando chega `fooBar`, então nenhum handler roda, uma linha `unknownCommand` vai para o log e nada é respondido. Teste.
- **CA3** (R3, R4.5, R9). Dado um `ping`, quando ele chega com `nonce = "abc"`, `nonce = 1.5`, `nonce = -1`, `nonce = 0/0`, sem `nonce` ou com um campo extra `x = 1`, então é recusado com `invalidArgs` e o campo culpado, logado e respondido com `rejected`, e o handler não roda. Teste, um por caso.
- **CA4** (R5). Dado o servidor na versão 1, quando chega um `ping` com `pv = 2`, sem `pv` ou com `args = nil`, então o servidor responde `versionMismatch { serverVersion = 1 }` e não executa. Teste.
- **CA5** (R5, R13). Dado o cliente, quando recebe `versionMismatch`, então mostra a mensagem uma vez e descarta, com log local, os pedidos seguintes. Teste de `net/` e checklist MP.
- **CA6** (R7). Dado o `ping` com burst 3, quando o mesmo jogador manda 5 pings no mesmo segundo, então 3 passam e 2 são descartados com log `rateLimited` e sem resposta; e com o relógio falso 5 s depois, passa mais 1. Teste.
- **CA7** (R7, multiplayer). Dado dois jogadores, quando o primeiro esgota o balde, então o segundo continua sendo atendido. Teste.
- **CA8** (R8). Dado um jogador mandando 100 pedidos inválidos em um minuto, então o log tem no máximo 10 linhas dele, e a primeira linha do minuto seguinte informa as suprimidas. Teste com relógio falso.
- **CA9** (R8). Dado um comando desconhecido com nome de 500 caracteres e quebras de linha, então a linha de log tem o nome cortado em 32 caracteres, numa linha só. Teste.
- **CA10** (R10). Dado um handler que lança erro, quando o comando chega, então o servidor loga o erro, responde `internalError` e atende normalmente o pedido seguinte. Teste.
- **CA11** (R12). Dado `net/`, quando a UI tenta enviar argumentos inválidos, então nada é enviado e o erro fica no log do cliente. Teste.
- **CA12** (R13, lag). Dado lag alto, quando os `pong` chegam atrasados ou fora de ordem, então o cliente casa cada um pelo `nonce` e ignora `nonce` desconhecido. Teste.
- **CA13** (R14). Dado baldes de jogadores parados, quando passa mais de um minuto e chega um pedido qualquer, então os baldes cheios são removidos. Teste com relógio falso.
- **CA14** (R4, R8, servidor real). Dado um servidor dedicado, quando um cliente em modo debug roda no console `sendClientCommand(getPlayer(), "ChurchRun", "ping", { pv = 1, nonce = "x" })` e depois `sendClientCommand(getPlayer(), "ChurchRun", "hack", { pv = 1 })`, então o log do servidor mostra `invalidArgs` (campo `nonce`) e `unknownCommand`, sem erro de Lua. Checklist MP, item 7.
- **CA15** (listen server). Dado o host jogando e um segundo cliente, quando os dois entram, então cada um recebe um `pong`, e o servidor registra um `ping` por cliente, sem duplicar. Checklist MP, item 8.
- **CA16** (R16, single player). Dado um jogo single player com o mod, quando o personagem é criado, então o console registra o `ping` do servidor e o `pong` do cliente. Teste do adaptador com `isClient`/`isServer` falsos e checklist manual.

## Impacto em dados

Nenhum. A spec não grava nada.
