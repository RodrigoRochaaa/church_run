# Roteiro de coleta dos dados de cada igreja

Para o Rodrigo, no modo debug do jogo. Vale para as 5 igrejas; a primeira é Rosewood (passo P06 do `ROADMAP.md`). O que cada ponto significa está na [SPEC-010](../specs/010-igrejas.md) §R4. Tempo: cerca de 30 minutos por igreja.

No fim, cole a lista preenchida no chat do Claude. Ele confere as distâncias, avisa o que precisar refazer e transforma o resultado em `defs/churches.lua`.

## 1. Preparar (uma vez)

1. Steam → Project Zomboid → Propriedades → Opções de inicialização: `-debug`.
2. Crie um jogo novo, sozinho, no modo personalizado (Sandbox), com a população de zumbis no mínimo ("Nenhum"). Assim dá para andar com calma.
3. Escolha Rosewood como cidade de nascimento.

## 2. Como copiar a posição do personagem

1. Fique em pé no quadrado que quer anotar.
2. Clique com o botão direito no chão → **Debug** → **Principal** → **Teletransportar**.
3. A janela mostra o X, o Y e o Z de onde o personagem está. Se você andou com ela aberta, clique em **Atualizar**.
4. Clique em **Copiar** e cole na lista do item 4 (Ctrl+V). O formato é `x - y - z`.
5. **Fechar**.

A mesma janela também teleporta: digite X, Y e Z e clique em OK. É útil para voltar a um ponto ou conferir a lista no fim.

## 3. O que anotar

| Ponto | Onde ficar em pé | Quantos |
|---|---|---|
| Altar | Na frente do altar ou do púlpito, virado para ele, no lugar onde alguém clicaria para começar o cerco | 1 |
| Porta | Do lado de fora da porta principal, na calçada, bem em frente à porta | 1 |
| Chegada do teleporte | Dentro da igreja, no térreo, num lugar livre (ex.: o corredor entre os bancos) | 1 |
| Nascimento | Do lado de fora, perto da igreja (calçada ou pátio), onde um personagem novo deveria aparecer | 1 |
| Âncoras | Na rua, ao ar livre: fim de rua, beco, estacionamento. Entre 40 e 60 tiles do altar, espalhadas pela frente, pelos fundos e pelos dois lados da igreja | 10 a 12 candidatas (o Claude escolhe de 6 a 10) |
| Sala de espera (opcional) | Dentro de um cômodo pequeno e fechado, na igreja ou do lado (sacristia, escritório) | 1 |

Dicas para as âncoras:
- 40 a 60 tiles são mais ou menos 2 a 3 quarteirões curtos. Compare com os números da janela: se o X ou o Y mudou entre 40 e 60 em relação ao altar e o outro mudou pouco, a distância está boa.
- Nunca dentro de prédio, quintal cercado, água ou mato fechado: os zumbis precisam conseguir andar dali até a porta.
- Melhor anotar candidatas a mais: as que caírem fora da faixa, o Claude descarta.

Se o terreno da igreja (pátio, estacionamento) passar de uns 30 tiles a partir do altar, anote isso em "observações". O raio do cerco pode ser ajustado.

## 4. Lista para preencher

```text
Igreja: Rosewood
altar:
porta:
chegada do teleporte:
nascimento:
sala de espera (opcional):
âncora 1:
âncora 2:
âncora 3:
âncora 4:
âncora 5:
âncora 6:
âncora 7:
âncora 8:
âncora 9:
âncora 10:
âncora 11:
âncora 12:
observações:
```
