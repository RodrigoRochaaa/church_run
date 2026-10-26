# SPEC-010 Igrejas e âncoras (dados)

- **Status:** aprovada em 26/10/2026, com as recomendações abaixo, sob a autonomia dada pelo Rodrigo. O código e os dados de Rosewood vêm depois da coleta do P06.
- **Versão mínima do jogo testada:** —
- **Fase:** 1 (`CONTEXT.md` §6), passo P06 do `ROADMAP.md`
- **ADRs ligadas:** [ADR-002](decisions/ADR-002-progressao-global.md)
- **Depende de:** GDD §2 (cadeia de cidades) e §4.3 (âncoras)

## Objetivo

O cerco, o nascimento e o teleporte precisam saber onde fica cada igreja: o ponto do altar, a porta, as âncoras de spawn e os pontos de chegada. Esta spec define esses dados em `defs/`, a ordem da campanha e a conferência que o servidor faz na carga, para um erro de digitação desativar só a igreja errada, e não derrubar o mod.

## Fora do escopo

- O que o servidor faz com os pontos: cerco e votação (SPEC-020), gerador de zumbis (SPEC-021), nascimento (SPEC-011), teleporte (SPEC-012), sala de espera (SPEC-030), ícones no mapa (SPEC-061).
- Conferir no mapa se uma âncora caiu na água ou dentro de um prédio: isso só dá para saber com a área carregada, e o gerador da SPEC-021 pula a âncora ruim na hora.
- Estado da campanha (igrejas conquistadas): fica no `ChurchRun_World` (SPEC-002), não aqui.

## Comportamento

- **R1. Onde.** Os dados ficam em `shared/ChurchRun/defs/churches.lua`, como tabela Lua sem lógica. Os números de regra (distâncias, quantidades) ficam no mesmo arquivo, em `rules`.
- **R2. Ordem da campanha.** `order` lista os IDs na ordem da cadeia do GDD §2: `rosewood`, `marchridge`, `muldraugh`, `westpoint`, `louisville`. Decidida em 26/10/2026 pela proposta do GDD (§14, decisão 1).
- **R3. Igreja sem dados ainda.** Um ID de `order` sem entrada em `churches` é uma igreja planejada. A campanha só vai até antes da primeira igreja planejada ou inválida, e o servidor registra isso no log (`churches.stop`).
- **R4. Pontos de cada igreja.** Todos com `x`, `y` e `z` inteiros:
  - `altar`: o quadrado em frente ao altar ou púlpito, dentro da igreja, onde o jogador fica para iniciar o cerco. As distâncias do cerco contam a partir dele;
  - `door`: o quadrado do lado de fora da porta principal, destino dos zumbis do cerco (GDD §4.3), com `z = 0`;
  - `spawn`: um quadrado externo perto da igreja, onde o personagem novo aparece quando ela é a conquistada mais recente (GDD §2.1). Em Rosewood, é também o nascimento do começo da campanha; `z = 0`;
  - `teleportArrival`: um quadrado livre dentro da igreja, no térreo (`z = 0`), onde chega quem usa o teleporte (GDD §2.2);
  - `anchors`: de 6 a 10 quadrados externos (`z = 0`), escolhidos à mão (fim de rua, beco, estacionamento), entre 40 e 60 tiles do `altar` (GDD §4.3);
  - `waitingRoom`: opcional, um quadrado dentro de um cômodo fechado perto da igreja, candidato a sala de espera. Quem decide se e como ele é usado é a SPEC-030.
- **R5. Raio do cerco.** `siegeRadius` (inteiro, padrão 30 tiles, GDD §4.1) é a distância do `altar` que conta para a votação e para a lista de participantes. Uma igreja pode trocar o padrão, de 20 a 60.
- **R6. Conferência na carga do servidor.** Uma função pura em `shared/ChurchRun/domain/churches/` confere cada igreja e devolve `ok, erros`:
  - campos obrigatórios presentes e inteiros, com os `z` exigidos em R4;
  - de 6 a 10 âncoras, cada uma entre 40 e 60 tiles do `altar` (distância reta em x e y);
  - duas âncoras a pelo menos 8 tiles uma da outra, para o lote não nascer no mesmo lugar;
  - `door` e `teleportArrival` dentro do `siegeRadius`;
  - IDs de `churches` que não estão em `order` são erro.
  
  Igreja com erro fica desativada, e cada erro vai para o log com o ID e o campo. Âncoras em menos de 3 dos 4 quadrantes em volta do altar geram só um aviso no log, porque a onda deveria chegar de vários lados (GDD §4.3), mas a igreja continua valendo.
- **R7. Nome para o jogador.** Cada igreja tem `nameKey`, chave de tradução do nome da cidade (EN, PT-BR e PT), nunca texto no código.

## Contrato

### Dados (`defs/churches.lua`)

```lua
return {
    rules = {
        minAnchors = 6, maxAnchors = 10,
        minAnchorDistance = 40, maxAnchorDistance = 60,
        minAnchorSpacing = 8,
        defaultSiegeRadius = 30, minSiegeRadius = 20, maxSiegeRadius = 60,
    },
    order = { "rosewood", "marchridge", "muldraugh", "westpoint", "louisville" },
    churches = {
        rosewood = {
            nameKey = "UI_ChurchRun_City_Rosewood",
            siegeRadius = 30,
            altar = { x = 0, y = 0, z = 0 },
            door = { x = 0, y = 0, z = 0 },
            spawn = { x = 0, y = 0, z = 0 },
            teleportArrival = { x = 0, y = 0, z = 0 },
            waitingRoom = { x = 0, y = 0, z = 0 },
            anchors = { { x = 0, y = 0, z = 0 } },
        },
    },
}
```

Os valores reais de Rosewood saem do roteiro de coleta ([`design/coleta-mapa.md`](../design/coleta-mapa.md)).

### Comandos de rede

Nenhum. O cliente recebe as igrejas pelas specs que precisarem delas (SPEC-061, por exemplo), sempre sem as âncoras.

### Dados salvos

Nenhum. `defs/` é dado do mod, não estado do jogo.

### Eventos e API do jogo usados

Nenhum nesta spec: a conferência é pura. A coleta usa a janela "Teletransportar" do modo debug (`ISTeleportDebugUI`, conferida no Lua vanilla do 42.21.0), que mostra as coordenadas do personagem e as copia.

## Segurança

| O que um cliente malicioso tenta | Como o servidor recusa |
|---|---|
| Mandar coordenadas de igreja ou de âncora | Não existe comando para isso; os pontos só vêm de `defs/`, no servidor |
| Descobrir as âncoras para esperar os zumbis | As âncoras nunca vão para o cliente |

## Critérios de aceite

- **CA1** (R6). Dado uma igreja com todos os pontos corretos, quando o servidor carrega, então ela vale e não há erro no log. Teste.
- **CA2** (R6). Dado uma âncora a 35 tiles ou a 65 tiles do altar, então a igreja fica desativada, e o erro cita a âncora. Teste.
- **CA3** (R6). Dado 5 ou 11 âncoras, ou duas âncoras a 4 tiles uma da outra, então a igreja fica desativada. Teste.
- **CA4** (R6). Dado `door` fora do `siegeRadius`, `z` diferente de 0 numa âncora ou um campo ausente, então a igreja fica desativada. Teste.
- **CA5** (R6). Dado âncoras só ao norte do altar, então a igreja vale, com um aviso no log. Teste.
- **CA6** (R3). Dado Rosewood com dados e March Ridge sem, então a campanha vai só até Rosewood, com `churches.stop` no log. Teste.
- **CA7** (R4, no jogo). Dado os pontos coletados de Rosewood, quando o Rodrigo se teleporta para cada um, então eles ficam onde a coleta anotou. Checklist do P06.

## Impacto em dados

Nenhum. Os dados salvos não mudam.
