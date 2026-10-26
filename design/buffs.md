# Buffs do sorteio (rascunho)

Status: rascunho, base para as specs SPEC-050 (sorteio e posse) e SPEC-051 (catálogo).
Atualizado em: 2026-10-26.
Alvo: Project Zomboid Build 42.20+, multiplayer, servidor autoritativo.

São 81 candidatos. A versão final do mod usa 30, escolhidos pelo Rodrigo.

---

## 1. Regras do sorteio

1. **Lista por personagem.** O servidor guarda, para cada personagem, os buffs que ele já tem.
2. **Oferta de 3.** Ao concluir uma igreja, o servidor sorteia 3 buffs entre os que o personagem ainda não tem.
3. **Sem repetir.** Só o buff escolhido sai da lista. Os outros que foram oferecidos voltam para a lista.
4. **Conflito com trait de criação.** Um buff que o personagem já tem como trait de criação (ex.: já nasceu Forte) não entra no sorteio.
5. **Escolhas por igreja:**

   | Igreja | Escolhas |
   | --- | --- |
   | 1 | 1 |
   | 2 | 2 |
   | 3 | 2 |
   | 4 | 3 |
   | 5 | 3 |

   Cada escolha é uma oferta separada de 3 opções. Numa campanha completa são 11 buffs.
6. **Perda na morte.** Ao morrer, todos os buffs são perdidos. O personagem novo começa com a lista cheia, e nada é recuperado.
7. **Servidor decide.** O sorteio é feito e validado no servidor. O cliente só envia "escolhi a opção N da oferta X" ou "quero rerollar a oferta X".

## 2. Regra de reroll

1. **1 reroll por oferta.** Em cada oferta, o jogador pode trocar as 3 opções por outras 3, uma vez, antes de escolher.
2. **O que sai volta.** As 3 opções descartadas voltam para a lista, mas não aparecem de novo no mesmo reroll. Se não houver 3 buffs novos disponíveis, o reroll mostra os que existirem.
3. **Não acumula.** Reroll não usado numa oferta não passa para a próxima.
4. **Depois do reroll, escolher é obrigatório.** Não há voltar para as opções anteriores.
5. **Buffs que mexem no reroll:**
   - **#53 Novo Sorteio:** +1 reroll em cada oferta (passa a 2 por oferta).
   - **#52 Sorte do Peregrino:** a próxima oferta mostra 4 opções em vez de 3.
6. **Segurança.** O servidor guarda quantos rerolls cada oferta já usou. Um pedido repetido ou fora da oferta ativa é recusado e registrado no log (idempotência e rate limit, como manda o CLAUDE.md).

Decisão em aberto: o reroll poderia custar moedas (ex.: 10 na Igreja 1, subindo por igreja) em vez de ser grátis. A proposta atual é 1 grátis por oferta.

---

## 3. Catálogo de candidatos

Viabilidade: **F** = fácil (dar trait, nível ou item), **M** = médio (mexe em dano, arma ou zumbis e precisa de teste no MP), **D** = difícil, **X** = não recomendado. VERIFICAR = nome de função ou comportamento do B42 a confirmar no jogo.

Regra para buffs que alteram a arma (alcance, pente, alvos, barulho): o efeito vale só enquanto o dono do buff segura a arma. Ao trocar, largar ou morrer, a arma volta ao normal.

### 3.1 Ideias do Rodrigo

| # | Buff | Efeito | Viab. | Como fazer |
| --- | --- | --- | --- | --- |
| 1 | Rajada Tripla | A cada 2 disparos, o 3º sai duplo | M | Contador de disparos no servidor; no 3º, +1 alvo/projétil (VERIFICAR tiro do B42). Plano B: 3º tiro com dano dobrado |
| 2 | Braço Longo | Machados e armas de duas mãos com +25% de alcance | M | Alcance aumentado ao equipar, original restaurado ao desequipar |
| 3 | Onda de Choque | Pulso derruba zumbis a até 3 tiles; recarga de 2 min | M | Derrubar em vez de empurrar. Dispara quando 3 zumbis ficam colados, antes do golpe. Sincronia no MP: VERIFICAR |

### 3.2 No estilo das ideias do Rodrigo

| # | Buff | Efeito | Viab. | Como fazer |
| --- | --- | --- | --- | --- |
| 68 | Quinto Golpe | A cada 4 golpes corpo a corpo, o 5º derruba o zumbi | M | Contador de golpes + queda forçada |
| 69 | Último Cartucho | A última bala do pente causa dano triplo | M | Ler a munição restante no disparo |
| 70 | Sequência Perfeita | 5 abates seguidos sem levar dano: próximo tiro não gasta munição | F | Contador zerado ao levar dano |
| 71 | Espingarda Sagrada | Espingardas acertam 1 zumbi a mais | M | +1 alvo só para espingardas (VERIFICAR) |
| 72 | Martelo do Juízo | Tacos e martelos têm 25% de chance de derrubar | M | Tipo da arma no acerto + queda |
| 73 | Lâmina Leve | Facas e armas leves de uma mão gastam 30% menos fôlego | M | Devolve fôlego após o golpe |
| 74 | Lança Longa | Lanças com +15% de alcance e 1 alvo a mais | M | Base do Braço Longo |
| 75 | Grito de Guerra | Início de cada onda: zumbis a até 8 tiles atordoados por 3 s | M | Base da Onda de Choque |
| 76 | Círculo Sagrado | 3 s parado cria zona de 2 tiles que derruba quem entra; recarga de 90 s | M | Checa se o jogador está parado |
| 77 | Contra-ataque | Após levar golpe, próximo ataque em 5 s com dano dobrado | M | Relógio ligado pelo dano recebido |
| 78 | Tiro de Misericórdia | Zumbis caídos levam dano dobrado de armas de fogo | M | Checa se o zumbi está no chão |
| 79 | Pulso Final | Ao terminar cada onda, cura 20% da vida | M | Fim de onda dispara cura (VERIFICAR vida no MP) |
| 80 | Eco da Fé | A cada 25 abates no cerco, recargas das habilidades caem 30 s | F | Contador que reduz os relógios |
| 81 | Pele de Pedra | 1º golpe recebido a cada 2 min não fere | D | Cancelar dano é incerto. Alternativa M: curar logo depois |

### 3.3 Armas de fogo

| # | Buff | Efeito | Viab. | Como fazer |
| --- | --- | --- | --- | --- |
| 4 | Mão Firme | +15% de dano com armas de fogo | M | Multiplicador no acerto |
| 5 | Bala Abençoada | 20% de chance de não gastar munição | F | Devolve 1 bala ao pente |
| 6 | Perfurante | A bala acerta 1 zumbi a mais | M | +1 alvo enquanto equipada (VERIFICAR) |
| 7 | Pente Estendido | +30% de munição no pente | M | Capacidade aumentada enquanto equipada |
| 8 | Tiro Abafado | Disparos 40% menos barulhentos | M | Raio de som reduzido enquanto equipada |
| 9 | Recarga Fantasma | +1 bala no pente a cada 20 s | F | Relógio no servidor |
| 10 | Choque de Recarga | Recarregar atordoa zumbis a até 2 tiles; recarga de 30 s | M | Base da Onda de Choque |
| 11 | Olho Morto | Tiro na cabeça com +50% de dano | D | Parte do corpo atingida (VERIFICAR) |
| 12 | Instrutor de Tiro | +1 em Mira | F | Nível de perícia |

### 3.4 Corpo a corpo

| # | Buff | Efeito | Viab. | Como fazer |
| --- | --- | --- | --- | --- |
| 13 | Lâmina Benta | +15% de dano corpo a corpo | M | Multiplicador no acerto |
| 14 | Golpe Varredor | Cada golpe acerta 1 zumbi a mais | M | +1 alvo enquanto equipada |
| 15 | Fio Eterno | Armas brancas gastam 50% menos | M | Chance de devolver a condição |
| 16 | Pisão Final | Pisar em zumbi caído mata na hora | M | Ataque no chão com dano letal (VERIFICAR) |
| 17 | Empurrão de Touro | O empurrão sempre derruba | M | Queda forçada no empurrão |
| 18 | Vampiro | Cada abate corpo a corpo cura um pouco | M | Cura no abate (VERIFICAR vida no MP) |
| 19 | Fúria | Cada abate dá +5% de dano por 10 s, até +25% | M | Contador com tempo |
| 20 | Fogo Sagrado | 10% de chance de incendiar o zumbi | M | Fogo pode se espalhar e queimar a igreja |
| 21 | Explosão de Fé | 5% dos abates derrubam zumbis em volta | M | Base da Onda de Choque |
| 22 | Armeiro | +1 em Manutenção | F | Nível de perícia |
| 23 | Golpe Rápido | Ataques 15% mais rápidos | D | Velocidade vem da animação |

### 3.5 Defesa e sobrevivência

| # | Buff | Efeito | Viab. | Como fazer |
| --- | --- | --- | --- | --- |
| 24 | Pele Grossa | Menos ferimentos por arranhão | F | Trait Thick Skinned |
| 25 | Milagre | Cura a infecção zumbi uma vez por personagem | M | Zera a infecção. Forte: talvez só a partir da Igreja 3 |
| 26 | Última Prece | Abaixo de 15% de vida, cura 30%, uma vez por cerco | D | Vida dividida por partes do corpo |
| 27 | Adrenalina | Abaixo de 30% de vida, corre sem cansar por 20 s; recarga de 3 min | M | Checagem de vida + fôlego |
| 28 | Retaliação | O zumbi que te acerta cai | M | Queda no evento de dano recebido |
| 29 | Cura Rápida | Ferimentos fecham mais rápido | F | Trait Fast Healer |
| 30 | Regeneração | Após 30 s sem dano, recupera vida devagar | M | Relógio + cura leve |
| 31 | Sangue Frio | Sem pânico e estresse durante o cerco | F | Zera pânico periodicamente |
| 32 | Armadura de Fé | Ganha o colete da loja atual no início de cada cerco | F | Entrega de item |
| 33 | Segunda Chance | Sobrevive a um golpe fatal com 1 de vida | X | Interceptar a morte no MP pode gerar personagem imortal |

### 3.6 Mobilidade e fôlego

| # | Buff | Efeito | Viab. | Como fazer |
| --- | --- | --- | --- | --- |
| 34 | Atlético | Corre mais e cansa menos | F | Trait Athletic |
| 35 | Fôlego Santo | Fôlego volta 25% mais rápido | M | Ajuste periódico de stamina |
| 36 | Maratonista | Após cada abate, corre 10 s sem gastar fôlego | M | Relógio ligado pelo abate |
| 37 | Passos Leves | Anda fazendo menos barulho | F | Trait Graceful |
| 38 | Ágil | Anda mais rápido mirando | F | Trait Nimble |
| 39 | Mochila de Peregrino | +3 de carga | M | Ajuste do peso máximo |

### 3.7 Economia e loja

| # | Buff | Efeito | Viab. | Como fazer |
| --- | --- | --- | --- | --- |
| 40 | Dízimo | +1 moeda a cada 10 abates | F | Contador no servidor |
| 41 | Fiel da Casa | −15% nos preços das lojas | F | Desconto na compra |
| 42 | Munição Divina | 1 caixa de munição da arma equipada a cada onda | F | Entrega de item |
| 43 | Abutre | 10% de chance de o zumbi deixar bandagem, munição ou comida | F | Item extra no corpo |
| 44 | Cofre Seguro | Metade das moedas passa para o próximo personagem | M | Exceção à regra "perde tudo" (decidir) |
| 45 | Colheita Final | Na última onda, cada zumbi vale 2 moedas | F | Regra no drop |

### 3.8 Grupo e sorteio

| # | Buff | Efeito | Viab. | Como fazer |
| --- | --- | --- | --- | --- |
| 46 | Aura de Coragem | Aliados a até 10 tiles sem pânico | M | Distância + zerar pânico |
| 47 | Médico de Campo | +1 em Primeiros Socorros e cura aliados mais rápido | M | Cura no aliado: VERIFICAR |
| 48 | Líder | Aliados a até 10 tiles ganham +10% de XP | M | Bônus no ganho de XP |
| 49 | Estandarte | Uma vez por cerco, planta um estandarte; aliados perto causam +10% de dano | M | Item no chão + distância |
| 50 | Batedor | A HUD mostra de onde vem a próxima leva | F | Servidor envia os pontos de spawn |
| 51 | Sentinela | Aviso quando zumbi chega a 15 tiles da igreja | F | Checagem de distância |
| 52 | Sorte do Peregrino | A próxima oferta mostra 4 opções | F | Regra do sorteio |
| 53 | Novo Sorteio | +1 reroll em cada oferta | F | Regra do reroll |

### 3.9 Traits e perícias do jogo

Todos F: o servidor só dá um trait ou nível que o jogo já tem. Nomes conferidos no B42.20 (VERIFICAR).

| # | Buff | Efeito | Origem |
| --- | --- | --- | --- |
| 54 | Forte | Mais dano corpo a corpo e carga | Trait Strong |
| 55 | Olhos de Águia | Vê mais longe | Trait Eagle Eyed |
| 56 | Audição Aguçada | Percebe zumbis atrás | Trait Keen Hearing |
| 57 | Olhos de Gato | Enxerga melhor no escuro | Trait Cat's Eyes |
| 58 | Corajoso | Menos pânico | Trait Brave |
| 59 | Discreto | Zumbis notam menos | Trait Inconspicuous |
| 60 | Destro | Move itens mais rápido | Trait Dextrous |
| 61 | Organizado | Mochilas guardam mais | Trait Organized |
| 62 | Estômago de Ferro | Menos intoxicação alimentar | Trait Iron Gut |
| 63 | Resiliente | Menos doenças comuns | Trait Resilient |
| 64 | Dorme Pouco | Precisa de menos sono | Trait Needs Less Sleep |
| 65 | Aprendiz Rápido | Ganha XP mais rápido | Trait Fast Learner |
| 66 | Come Pouco | Fome mais lenta | Trait Light Eater |
| 67 | Carpinteiro | +1 em Carpintaria (barricadas melhores) | Perícia |

---

## 4. Resumo

| Viabilidade | Quantidade |
| --- | --- |
| Fácil | 35 |
| Médio | 41 |
| Difícil | 4 |
| Não recomendado | 1 |
| **Total** | **81** |

Sugestão para os 30 finais: cerca de 18 efeitos novos e no máximo 12 traits do jogo.
