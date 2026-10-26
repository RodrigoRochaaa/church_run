# SPEC-002 Persistência

- **Status:** rascunho
- **Versão mínima do jogo testada:** — (API conferida no código do 42.21.0 em 26/10/2026; nada testado no jogo ainda)
- **Fase:** 0 (`CONTEXT.md` §6)
- **ADRs ligadas:** [ADR-001](decisions/ADR-001-servidor-autoritativo.md), [ADR-002](decisions/ADR-002-progressao-global.md), [ADR-004](decisions/ADR-004-id-e-namespace.md)
- **Depende de:** [SPEC-001](001-protocolo-comandos.md) (motivo `serverDataUnavailable` no `rejected`)

## Objetivo

O estado do mod tem de sobreviver a reinícios do servidor e a atualizações do mod. Esta spec define onde os dados ficam (Global ModData do servidor) e o formato versionado (`schemaVersion`). Define também como as migrações levam dados antigos até a versão atual sem perder nada, e o que o servidor faz com dados que não entende.

## Fora do escopo

- Os campos de cada funcionalidade (campanha, cerco, moedas, buffs): cada spec acrescenta os seus, com versão nova de esquema e migração (R3).
- Dados por jogador (`ChurchRun_Players`): chegam com a primeira spec que precisar, que também decide a chave do jogador (username ou SteamID).
- Envio do estado ao cliente: a SPEC-001 define o canal, e a spec da funcionalidade define o comando.
- Backup fora do jogo, exportação e comandos de admin para apagar ou restaurar dados.

## Comportamento

- **R1. Onde.** Todo dado persistente do mod fica em Global ModData do servidor, em chaves com prefixo `ChurchRun_` (`CLAUDE.md` §5). Esta versão cria uma chave, `ChurchRun_World`, com o estado global ([ADR-002](decisions/ADR-002-progressao-global.md)), e a cópia de segurança dela (R5).
- **R2. Só o servidor escreve.** O `app` acessa os dados pelo port `Storage`, e só o adaptador `Storage` chama `ModData`. O servidor não registra `OnReceiveGlobalModData` para chaves `ChurchRun_`. Assim, um cliente que transmita uma tabela com esse nome não muda nada (ver Segurança).
- **R3. Versão.** Toda chave tem `schemaVersion` (inteiro, a partir de 1) no topo. A versão atual de cada chave e a lista de migrações ficam em `server/ChurchRun/migrations/`. Mudou o formato salvo: versão nova, migração e teste, no mesmo PR.
- **R4. Carga.** No `OnInitGlobalModData` do servidor, para cada chave:
  1. chave vazia (mundo novo, ou mod instalado num mundo que já existia) → grava os valores iniciais da versão atual;
  2. `schemaVersion` igual à atual → usa como está;
  3. `schemaVersion` menor → aplica as migrações em ordem (v1→v2→v3...), uma linha de log por passo (R5);
  4. `schemaVersion` maior que a atual (mod rebaixado) → modo seguro (R6);
  5. tabela com dados, mas sem `schemaVersion` inteiro → modo seguro (R6).
  
  No fim de uma carga sem modo seguro, `bootCount` soma 1 e o servidor registra uma linha `storage.loaded` com chave, versão, `bootCount` e `createdAtMs`.
- **R5. Migração tudo-ou-nada.** As migrações rodam sobre uma cópia dos dados. Só se todos os passos derem certo: (a) o original é copiado para `ChurchRun_World_backup`, que guarda só a última versão anterior; (b) a cópia migrada substitui o conteúdo da chave, na mesma tabela; (c) o log registra a versão de origem e a de destino. Se um passo falhar, os dados originais e o backup ficam intactos, o erro vai para o log e o servidor entra em modo seguro.
- **R6. Modo seguro.** O servidor não escreve na chave e registra um erro claro, por exemplo: "dados do church_run na versão 9; este mod entende até a 1: atualize o mod ou restaure o backup". Enquanto isso, o roteador da SPEC-001 só atende `ping`; os outros comandos recebem `rejected` com o motivo `serverDataUnavailable`. O mesmo vale antes de a carga terminar.
- **R7. Migrações são funções puras**, uma por passo (`v1_to_v2`): recebem a tabela da versão N e devolvem `ok, tabelaN+1` ou `false, erro`, sem API do jogo. A lista é conferida na carga e nos testes: passos contínuos de 1 até a versão atual, sem buraco nem repetição. Lista inválida = modo seguro, com log.
- **R8. Durabilidade.** O jogo grava a Global ModData junto com o mundo, no salvamento automático e ao desligar o servidor. Uma queda entre dois salvamentos perde as mudanças desse intervalo; o mod não tenta contornar isso.
- **R9. Formato v1 de `ChurchRun_World`:**

  ```lua
  {
      schemaVersion = 1,
      createdAtMs = 1792990000000, -- relógio real (getTimestampMs) quando os dados foram criados
      bootCount = 3,               -- soma 1 a cada carga do servidor sem modo seguro
  }
  ```

  Valores iniciais (R4.1): `createdAtMs` = agora e `bootCount` = 0, que a própria carga leva a 1. Os dois campos servem ao diagnóstico: aparecem na linha `storage.loaded`, e é por eles que se vê que os dados sobreviveram a um reinício. As specs da campanha (SPEC-010, SPEC-011) acrescentam os campos de progresso na v2.
- **R10. Só tipos simples.** Os dados salvos só têm string, número, booleano e tabelas desses tipos, nunca funções nem objetos do jogo, para o save conseguir gravar.
- **R11. Tamanho limitado.** Nada cresce sem limite na Global ModData. Históricos e logs ficam no log do servidor. Toda spec que acrescentar uma lista declara o tamanho máximo dela.

## Contrato

### Dados salvos

| Chave | Conteúdo | Versão |
|---|---|---|
| `ChurchRun_World` | R9 | 1 |
| `ChurchRun_World_backup` | Cópia de `ChurchRun_World` antes da última migração (R5); não existe enquanto não houver migração | a da cópia |

### Log

Eventos: `storage.loaded`, `storage.created`, `storage.migrated` (de, para), `storage.safeMode` (motivo, versão encontrada, versão suportada), `storage.migrationFailed` (passo, erro).

### Eventos e API do jogo usados

| Uso | API | Conferido |
|---|---|---|
| Carregar no início do servidor | `Events.OnInitGlobalModData`, callback `(newGame)` | Umbrella 42.21.0; usado pelo vanilla no servidor (`ProfessionVehicles.lua`). VERIFICAR B42 se dispara antes de o primeiro jogador entrar |
| Abrir a tabela viva de uma chave | `ModData.getOrCreate(tag)` | Umbrella 42.21.0 e Lua vanilla do 42.21.0 |
| Substituir o conteúdo na migração | Limpar e copiar na própria tabela, sem `ModData.add` | Escolha para usar só a API que o vanilla usa |
| Relógio real | `getTimestampMs()` | Umbrella 42.21.0 |

## Segurança

| O que um cliente malicioso tenta | Como o servidor recusa |
|---|---|
| Sobrescrever `ChurchRun_World` com `ModData.transmit` a partir do cliente | R2: no 42.21.0, o pacote de transmissão só dispara `OnReceiveGlobalModData` no servidor, sem gravar nada, e o servidor não trata esse evento para chaves `ChurchRun_`. Conclusão tirada das classes do jogo (`GlobalModDataPacket`); VERIFICAR B42 em jogo (CA10) |
| Ler a Global ModData com `ModData.request` | Possível: no 42.21.0, qualquer jogador logado pode pedir uma chave (`GlobalModDataRequestPacket` chama `GlobalModData.receiveRequest`; VERIFICAR B42). Por isso nada secreto vai para a Global ModData: sementes de sorteio, ofertas futuras, dados de outros jogadores que não devam ser vistos |
| Dados corrompidos ou editados à mão no save | R4.5 e R6: modo seguro, sem sobrescrever |
| Rebaixar o mod para forçar a perda de dados | R4.4 e R6: modo seguro, sem sobrescrever |

## Critérios de aceite

- **CA1** (R4.1, R9). Dado um mundo novo, quando o servidor carrega, então `ChurchRun_World` fica `{ schemaVersion = 1, createdAtMs = <agora>, bootCount = 1 }` e o log tem `storage.created` e `storage.loaded`. Teste com `Storage` e `Clock` falsos.
- **CA2** (R4.2, R8, R9). Dado um servidor dedicado com dados v1, quando ele é desligado com `quit` e ligado de novo, então `bootCount` sobe 1 e `createdAtMs` não muda. Checklist MP, item 5.
- **CA3** (R4.3, R5, R7). Dado migrações de teste v1→v2→v3 e dados v1, quando o servidor carrega, então os dados ficam na v3, o backup fica com o conteúdo v1 e o log tem as duas migrações. Teste.
- **CA4** (R5). Dado que o passo v2→v3 falha, quando o servidor carrega dados v1, então os dados continuam v1 com os mesmos valores, o backup não muda e o servidor entra em modo seguro. Teste.
- **CA5** (R4.4, R6). Dado dados com `schemaVersion = 9`, quando o servidor carrega, então nada é gravado, o log tem `storage.safeMode`, `ping` continua respondendo e qualquer outro comando recebe `rejected` com `serverDataUnavailable`. Teste.
- **CA6** (R4.5, R6). Dado a tabela `{ foo = 1 }` sem `schemaVersion`, quando o servidor carrega, então entra em modo seguro e `foo` continua lá. Teste.
- **CA7** (R7). Dado uma lista de migrações com buraco (1→2, depois 3→4) ou com passo repetido, então a conferência acusa o erro. Teste.
- **CA8** (R10). Os valores iniciais e a saída de cada migração só têm tipos simples. Teste.
- **CA9** (R2). Nenhum arquivo fora de `adapters/` e dos `Main.lua` chama `ModData`. Lint.
- **CA10** (R2, segurança). Dado um servidor dedicado, quando um cliente em modo debug roda no console `local t = ModData.getOrCreate("ChurchRun_World"); t.bootCount = 999; ModData.transmit("ChurchRun_World")` e o servidor reinicia, então o `bootCount` do servidor segue a contagem normal. Checklist MP.
- **CA11** (morte). Dado um jogador que morre e cria outro personagem, então `ChurchRun_World` não muda. Checklist MP, item 6.

## Impacto em dados

Primeira versão do esquema (v1). Como não há dados antigos, não há migração real. O mecanismo de migração é testado com migrações de teste (CA3, CA4, CA7).

## Questões em aberto

1. **Backup antes de migrar** (R5). Recomendo manter: custa uma cópia pequena e dá ao admin um caminho de volta sem ferramenta externa. A alternativa é só registrar a migração no log.
2. **Single player.** A persistência é a mesma (Global ModData do save local). Segue a decisão da questão 1 da SPEC-001.
