# CLAUDE.md: QuestMod (Project Zomboid, Build 42, multiplayer)

Mod de missões com recompensas e itens novos, para servidores multiplayer do Project Zomboid **Build 42 (42.20+)**. Não há suporte a B41.
Plano de arquitetura de referência: https://claude.ai/artifact/TbL7fUBqqyNAfFwZNwhjhQ

Estas regras valem para qualquer pessoa ou agente que mexa no repositório. Se uma regra atrapalhar, proponha a mudança neste arquivo em vez de ignorá-la.

---

## 1. Princípios (em ordem de prioridade)

1. **O servidor é a única fonte da verdade.** Gerar missões, contar progresso, validar conclusão, entregar recompensa e gravar dados acontece só em `server/`. O cliente pede e mostra.
2. **O jogo é um detalhe de infraestrutura.** A regra de negócio (missões, objetivos, recompensas) não conhece a API do Project Zomboid. Toda chamada ao jogo passa por um adaptador. Quando um patch do jogo quebrar algo, a correção deve caber em um arquivo de adaptador.
3. **Spec antes de código.** Nenhuma funcionalidade é implementada sem uma spec aprovada em `specs/`.
4. **Extensão sem modificação.** Um tipo novo de objetivo ou de recompensa é um arquivo novo registrado num registro (registry), sem editar o motor.
5. **Simples e explícito.** Código fácil de ler vale mais que código esperto. Nada de abstração "para o futuro" sem uma spec que a peça.

---

## 2. Fluxo spec-driven

Todo trabalho segue: **spec → plano de tarefas → testes → implementação → verificação → atualização da spec**.

### 2.1 Estrutura das specs

```
specs/
  README.md                  # índice das specs e status
  000-template.md            # modelo obrigatório
  001-protocolo-comandos.md
  002-persistencia.md
  003-missao-entrega.md
  ...
  decisions/                 # ADRs: decisões de arquitetura
    ADR-001-servidor-autoritativo.md
```

Cada spec tem, nesta ordem:

- **ID e título** (`SPEC-003 Missão de entrega`), **status** (`rascunho`, `aprovada`, `implementada`, `obsoleta`) e versão mínima do jogo testada.
- **Objetivo**: o problema, em 2 a 3 frases.
- **Fora do escopo**: o que esta spec não faz.
- **Comportamento**: regras numeradas (`R1`, `R2`...), cada uma verificável.
- **Contrato**: comandos de rede (nome, argumentos, tipos, limites, resposta), formato de dados salvos e eventos usados.
- **Segurança**: o que um cliente malicioso poderia tentar e como o servidor recusa.
- **Critérios de aceite**: cenários `Dado / Quando / Então`, incluindo os de erro e de multiplayer (dois jogadores, lag, desconexão).
- **Impacto em dados**: muda o esquema salvo? Então inclui a migração.

### 2.2 Regras do fluxo

- Antes de codar, leia a spec inteira e as ADRs ligadas. Se a spec estiver ambígua ou incompleta, pare e proponha a alteração da spec; não "adivinhe" no código.
- Cada commit e PR cita o ID da spec e das regras que implementa (`SPEC-003 R2, R4`).
- Código sem spec correspondente é removido ou ganha uma spec.
- Mudou o comportamento? A spec é atualizada no mesmo PR.
- Decisão de arquitetura que afeta mais de um módulo vira uma ADR curta (contexto, decisão, consequências).

---

## 3. Arquitetura

### 3.1 Camadas

```
domain     → regras puras: missões, objetivos, recompensas, validação. Sem API do jogo.
app        → casos de uso do servidor: aceitar, progredir, concluir, gerar. Orquestra domain + ports.
ports      → interfaces (tabelas com funções) que o app precisa: Inventory, Storage, Clock, Net, Log, Players.
adapters   → implementação dos ports usando a API do PZ B42. Único lugar que chama o jogo.
ui         → interface do cliente. Fala só com o cliente de rede e com os dados recebidos.
```

Regras de dependência (setas só para dentro):

- `domain` não depende de nada além de `shared/QuestMod/util`.
- `app` depende de `domain` e de `ports`, nunca de `adapters`.
- `adapters` dependem de `ports` e da API do jogo.
- `ui` não acessa `server/`, nem ModData de outro jogador, nem decide nada.
- A ligação (qual adaptador implementa qual port) acontece só nos arquivos de bootstrap: `server/QuestMod/Main.lua` e `client/QuestMod/Main.lua`.

### 3.2 Estrutura de pastas do repositório

```
Contents/mods/QuestMod/
  common/                         # assets compartilhados (texturas, ícones, poster)
  42/
    mod.info                      # id=QuestMod, versionMin=42.20
    media/
      scripts/QuestMod_items.txt  # module QuestMod { item ... }
      lua/
        shared/QuestMod/
          domain/                 # Quest, Objective, Reward, Validators
          defs/                   # definições de missões e tabelas de recompensa (dados)
          protocol/               # nomes de comandos, esquemas de argumentos, versão do protocolo
          util/                   # funções puras genéricas
        client/QuestMod/
          Main.lua                # bootstrap do cliente
          net/                    # envio de pedidos e tratamento de respostas
          ui/                     # janelas e notificações
          adapters/               # eventos de cliente do jogo
        server/QuestMod/
          Main.lua                # bootstrap do servidor
          app/                    # casos de uso
          objectives/             # um rastreador por tipo de objetivo
          rewards/                # um pagador por tipo de recompensa
          adapters/               # inventário, ModData, rede, log, jogadores
          migrations/             # migrações de esquema de dados
specs/
tests/                            # testes de Lua puro fora do jogo
tools/                            # scripts de lint, empacotamento e checagens
```

- Todo arquivo Lua fica dentro de uma subpasta `QuestMod/` para evitar colisão com outros mods.
- Nenhum arquivo é colocado direto em `lua/shared`, `lua/client` ou `lua/server`.

### 3.3 Pontos de extensão

- **Objetivos**: cada tipo (`kill`, `collect`, `deliver`, `visit`, `survive`) é um módulo em `server/QuestMod/objectives/` que se registra em `ObjectiveRegistry` com `id`, `validateDef(def)`, `onEvent(state, event)` e `isComplete(state, def)`.
- **Recompensas**: cada tipo (`item`, `xp`, `currency`, `unlock`) é um módulo em `server/QuestMod/rewards/` registrado em `RewardRegistry` com `validateDef(def)` e `pay(ctx, player, def)`.
- Registro duplicado de um mesmo `id` gera erro na carga, não sobrescrita silenciosa.
- Outros mods podem registrar tipos novos pela API pública documentada em `specs/`.

### 3.4 Isolamento contra atualizações do jogo

- Toda chamada à API do PZ (globais como `getPlayer`, `sendClientCommand`, `sendServerCommand`, `ModData`, `Events`, criação de itens, XP) vive em `adapters/`. Grep por esses nomes fora de `adapters/` e dos bootstraps deve dar vazio; o lint confere isso.
- IDs de itens vanilla (`Base.X`) só aparecem em `defs/` e são validados na carga do servidor: ID inexistente é logado e a missão é desativada, sem derrubar o mod.
- Comportamentos do jogo que mudam entre patches (ex.: sincronização de inventário no MP) ficam atrás de um port, com um comentário apontando a spec ou ADR que os descreve.
- Ao subir a versão do jogo suportada: rodar o checklist de compatibilidade (seção 7), atualizar `versionMin` e registrar a mudança no `CHANGELOG.md`.

---

## 4. Segurança e autoridade do servidor

Trate todo pedido vindo do cliente como hostil.

- **O cliente manda intenções, não fatos.** Ex.: `{ questId = "q_entrega_01" }`. Nunca quantidades, recompensas, contagens ou "já concluí".
- **Todo comando tem esquema** em `shared/QuestMod/protocol/`: campos permitidos, tipos, tamanho máximo de string, faixa numérica. Campo desconhecido, tipo errado ou valor fora da faixa: recusa e log. A validação acontece antes de qualquer lógica.
- **Comando desconhecido** é ignorado e logado, nunca gera erro não tratado.
- **Revalidar no servidor** tudo que o cliente afirmar: itens realmente no inventário do jogador, distância, missão ativa, pré-requisitos.
- **Idempotência**: concluir marca a missão como concluída **antes** de pagar; um segundo pedido igual não paga de novo. Operações de pagamento são tudo-ou-nada.
- **Rate limit** por jogador e por comando, configurável, com log ao exceder.
- **Admin**: comandos administrativos checam o nível de acesso do jogador no servidor. Esconder botão na UI não é segurança.
- **Identidade**: o jogador é sempre o que o servidor recebe no evento (`OnClientCommand`), nunca um nome ou ID vindo nos argumentos.
- **Desconexão**: estado temporário (entrega em andamento, reserva de item) é limpo no evento de desconexão para não duplicar itens.
- **Nada de `loadstring`/execução de código vindo de dados**, inclusive de arquivos de config do servidor.
- **Logs de auditoria** no servidor para toda recompensa paga e todo pedido recusado: jogador, comando, motivo, horário. Sem dados pessoais além do nome de usuário.
- **Versão do protocolo** em `protocol/`: cliente com versão diferente recebe uma mensagem clara e não envia comandos.

Toda spec que adiciona um comando precisa da seção **Segurança** preenchida.

---

## 5. Dados e persistência

- Progresso dos jogadores e estado global ficam em **Global ModData** no servidor, em chaves com prefixo `QuestMod_` (ex.: `QuestMod_Players`, `QuestMod_World`).
- Todo dado salvo tem `schemaVersion`. Ao carregar, `migrations/` leva os dados de qualquer versão antiga até a atual, passo a passo (`v1→v2→v3`). Migração nunca apaga dados sem log.
- O formato salvo é definido na spec `002-persistencia` e só muda com nova versão de esquema.
- O cliente recebe só a fatia de dados que é dele, por `sendServerCommand`. `ModData.transmit` só para dados públicos e pequenos.
- Considere que a entrega de rede não é garantida: o cliente pode pedir o estado de novo (`sync`) a qualquer momento, e a resposta é sempre o estado completo dele, nunca um delta que dependa de mensagens anteriores.
- Nada de dados de missão em ModData de itens ou do personagem que valha recompensa (o cliente tem mais influência sobre esses dados).

---

## 6. Código limpo em Lua (Kahlua, Lua 5.1)

### 6.1 Estilo

- Identificadores, nomes de arquivo e IDs técnicos em **inglês**; comentários, specs e textos de commit em português. Textos para o jogador só via arquivos de tradução (EN e PT-BR no mínimo), nunca escritos no código.
- Módulos: `local M = {}` ... `return M`. Nada de variáveis globais; o único global permitido é a tabela raiz `QuestMod`, criada no bootstrap.
- Sempre `local` para variáveis e funções.
- Nomes: `PascalCase` para módulos e "classes", `camelCase` para funções e variáveis, `UPPER_SNAKE` para constantes.
- Funções curtas, com uma responsabilidade. Acima de ~40 linhas, quebre.
- Sem números ou strings mágicas: constantes em `protocol/` ou `defs/`.
- Sem código comentado no repositório.
- Comentários explicam **por quê**, não o quê. Comportamento estranho do jogo leva comentário com a versão em que foi observado.

### 6.2 Cuidados específicos do Project Zomboid

- Kahlua não tem `io` nem `os` completos; não use bibliotecas externas que dependam deles.
- Listas Java começam em 0 e usam `:size()`/`:get(i)`; converta para tabela Lua no adaptador, nunca no domínio.
- Guarde em `local` o resultado de chamadas Java repetidas dentro de loops.
- Proibido lógica pesada em `OnTick` e `OnPlayerUpdate`. Prefira eventos específicos (`OnZombieDead`, `EveryOneMinute`, `EveryTenMinutes`) e trabalho em lotes.
- Funções registradas em `Events` são nomeadas (não anônimas), para poder remover.
- Nunca sobrescreva funções vanilla. Se precisar alterar comportamento, encadeie: guarde a original, chame-a, e acrescente o seu comportamento.
- Separe cliente e servidor por pasta. `isClient()`/`isServer()` só em casos documentados; lembre que no listen server o host roda os dois lados.
- Erros: funções do domínio retornam `ok, err` (sem `error()` para fluxo normal). Os pontos de entrada de eventos e comandos usam `pcall` e logam a falha, para que um bug não derrube o servidor.

---

## 7. Testes e verificação

- **Testes unitários** (Lua 5.1 + `busted`, em `tests/`) cobrem `domain`, `app`, `protocol`, registros e migrações, usando ports falsos. Esses módulos precisam rodar fora do jogo; se não rodam, a dependência do jogo está no lugar errado.
- Todo bug corrigido ganha um teste que falhava antes.
- Todo critério de aceite da spec vira pelo menos um teste ou um item do checklist manual.
- **Checklist manual de multiplayer** (em `specs/checklist-mp.md`), obrigatório antes de cada release:
    1. Servidor dedicado B42 local + 2 clientes.
    2. Os dois jogadores aceitam e concluem a mesma missão ao mesmo tempo.
    3. Clique duplo e reenvio no concluir não pagam duas vezes.
    4. Desconectar no meio de uma entrega não duplica itens.
    5. Reiniciar o servidor mantém o progresso.
    6. Morte do personagem segue a regra da spec.
    7. Comando com argumentos inválidos é recusado e logado.
    8. Listen server (host jogando) funciona sem execução duplicada.
    9. Log do servidor sem erros de Lua do mod.
- **Checklist de compatibilidade** ao atualizar o jogo: carga do mod sem erro, validação de IDs de itens, scripts de itens sem erro de parse no console, checklist de MP completo.

---

## 8. Git, PRs e releases

- Um PR por spec ou por parte dela; título com o ID (`SPEC-003: missão de entrega`).
- Commits pequenos e com mensagem no imperativo, citando a spec.
- PR só é aceito com: testes passando, lint passando, spec atualizada, `CHANGELOG.md` atualizado e checklist de MP marcado quando tocar em rede, dados ou recompensas.
- Versionamento semântico do mod (`modversion` no `mod.info`):
    - **major**: muda o esquema de dados de forma incompatível ou o protocolo de rede;
    - **minor**: funcionalidade nova compatível;
    - **patch**: correção.
- Toda release informa no Workshop a versão mínima do jogo e a linha exata de `Mods=` (com `\` antes do ID no B42), e avisa para os jogadores reiniciarem o jogo após atualizar, por causa do checksum de Lua.

---

## 9. Definição de pronto

Uma tarefa só está pronta quando:

- [ ] A spec está aprovada e as regras implementadas estão citadas no PR.
- [ ] Nenhuma chamada à API do jogo fora de `adapters/` e bootstraps.
- [ ] Todo comando novo tem esquema, validação, rate limit e seção de segurança na spec.
- [ ] Mudança de dados tem `schemaVersion` novo e migração testada.
- [ ] Textos para o jogador estão em tradução EN e PT-BR.
- [ ] Testes unitários e lint passam.
- [ ] Checklist de MP executado, quando aplicável.
- [ ] Spec, CHANGELOG e, se houver decisão nova, ADR atualizados.

---

## 10. O que o agente (Claude) deve fazer

- Ler este arquivo, a spec da tarefa e as ADRs relacionadas antes de mudar código.
- Propor mudanças na spec antes de implementar algo que ela não cobre.
- Não inventar funções da API do PZ: se não tiver certeza de que um método existe no B42, diga e isole a chamada num adaptador com um comentário `-- VERIFICAR B42`.
- Preferir a mudança mínima que cumpre a spec. Refatorações maiores viram uma spec ou ADR própria.
- Ao terminar, listar o que foi feito, quais regras da spec foram cobertas e o que ficou para teste manual.
