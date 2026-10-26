# church_run: documento de design (v0.2)

Status: rascunho para aprovação. Atualizado em 2026-10-26.
Alvo: Project Zomboid Build 42.20+, multiplayer, Lua puro, servidor autoritativo, código aberto e gratuito.

Este arquivo é a referência principal do design. Ele substitui a parte de design do doc "Conquista de Igrejas: viabilidade e etapas" (a ordem das cidades e a economia mudaram).

Arquivos ligados:
- [lojas.md](lojas.md): catálogo completo com IDs e preços.
- [buffs.md](buffs.md): os 81 buffs candidatos e as regras de sorteio e reroll.
- [../CLAUDE.md](../CLAUDE.md): regras de código, arquitetura e fluxo de specs.

Legenda de viabilidade: **F** = fácil, **M** = médio (precisa de teste no multiplayer), **D** = difícil, **X** = não recomendado. **VERIFICAR** = comportamento da API do B42 a confirmar no jogo antes da spec ser aprovada.

---

## 1. O jogo em uma frase

Um grupo atravessa Knox Country de sul a norte conquistando 5 igrejas. Cada conquista é um cerco de ondas de zumbis, e entre um cerco e outro o grupo cumpre missões, junta moedas, compra equipamento e escolhe buffs.

### 1.1 Ciclo principal

1. **Missões na cidade:** chegar à igreja, achar a relíquia, preparar a defesa. Contratos extras dão moedas.
2. **Loja:** cada zumbi morto vale 1 moeda, gasta nas lojas das igrejas já conquistadas.
3. **Cerco:** ativar o altar com a relíquia e sobreviver às ondas até o timer zerar.
4. **Recompensa:** a igreja vira território do servidor, com spawn, teleporte, loja maior e sorteio de buffs.
5. Seguir para a próxima cidade, que é vizinha.

### 1.2 Decisões já tomadas

| Data | Decisão |
| --- | --- |
| 2026-10-25 | Só Build 42, Lua puro, servidor autoritativo |
| 2026-10-26 | Desenvolvimento guiado por specs (CLAUDE.md) |
| 2026-10-26 | Progressão do servidor inteiro: uma igreja vencida vale para todos |
| 2026-10-26 | Todo zumbi dá 1 moeda, dentro e fora do cerco |
| 2026-10-26 | Buffs: oferta de 3, sem repetir, perdidos na morte, 1 reroll grátis por oferta |
| 2026-10-26 | Catálogo das lojas cumulativo e completo na igreja 3 |
| 2026-10-26 | Igrejas conquistadas viram pontos de teleporte entre si |
| 2026-10-26 | ID do mod `church_run` e namespace do código `ChurchRun` ([ADR-004](../specs/decisions/ADR-004-id-e-namespace.md)) |
| 2026-10-26 | Licença: MIT para o código e CC BY 4.0 para a arte ([ADR-003](../specs/decisions/ADR-003-licenca.md)) |
| 2026-10-26 | Kit do Peregrino numa mochila básica, já na Fase 1. Enquanto Rosewood não for conquistada, a mochila traz a relíquia de Rosewood |
| 2026-10-26 | Da igreja 2 em diante, a relíquia é escondida e precisa ser achada (seção 7.1) |

---

## 2. Mundo: 5 cidades vizinhas em linha

O B42 tem um único mapa, Knox Country, com 12 cidades. A cadeia abaixo liga cidades vizinhas de sul a norte, e a dificuldade sobe junto com a densidade de cada uma.

| Igreja | Cidade | Distância até a anterior (aprox.) | Perfil |
| --- | --- | --- | --- |
| 1 | Rosewood | ponto de partida | Cidade de início para iniciantes, com corpo de bombeiros. A prisão a leste é uma área de risco |
| 2 | March Ridge | ~2.300 tiles | Bairro residencial denso e planejado, com tom militar |
| 3 | Muldraugh | ~2.900 tiles | Cidade-corredor industrial na rodovia, boa em ferramentas |
| 4 | West Point | ~3.200 tiles | Densa e de alta pressão, perto do rio |
| 5 (final) | Louisville | ~5.400 tiles, passando por Valley Station | A maior e mais densa cidade do mapa |

Distâncias em linha reta entre os pinos das cidades no mapa ([pzfans](https://pzfans.com/knox_country_breakdown_zomboids_map_survival_uncovered/)). Riverside, a primeira proposta para a igreja 2, ficou de fora: ela fica a ~5.400 tiles de West Point e não encaixa numa linha de vizinhas.

- **Valley Station** fica entre West Point e Louisville. Ela vira o cenário de uma missão de passagem ("Abrir caminho para Louisville"), não uma igreja.
- **Cidades novas do B42** (Echo Creek, Ekron, Irvington, Brandenburg, Fallas Lake) formam uma segunda cadeia natural no oeste. Ficam para uma expansão.
- **A igreja de cada cidade** é escolhida no jogo em modo debug: coordenadas do altar, raio do cerco e pontos de spawn (seção 4.3). Esta é a primeira tarefa da SPEC-010.

### 2.1 Onde o jogador nasce

1. Sem igreja conquistada: nasce em Rosewood, perto da igreja 1.
2. Com igrejas conquistadas: nasce na igreja conquistada mais recente. Para ir às outras, usa o teleporte.
3. Implementação: o servidor teleporta o personagem novo para o ponto de nascimento certo logo após ele aparecer. O admin pode deixar uma única região no `spawnregions` para a tela de escolha não confundir.

### 2.2 Teleporte entre igrejas

| Regra | Valor proposto |
| --- | --- |
| Onde | No altar de qualquer igreja conquistada, para qualquer outra conquistada |
| Custo | 10 moedas por salto |
| Ativação | 10 s parado no altar. Cancela se o jogador se mover ou levar dano |
| Recarga | 5 min reais por jogador |
| Durante um cerco | Ninguém sai da igreja em cerco por teleporte. Quem está fora pode entrar como reforço só na pausa entre ondas, e passa a valer a regra de morte (seção 4.6) |
| Carga | Leva o que está no inventário. Veículos não teleportam |
| Chegada | Ponto fixo dentro da igreja, no térreo |

Como funciona por baixo: o cliente pede o teleporte. O servidor confere conquista, saldo, recarga e se o jogador está parado, desconta as moedas, manda o cliente se mover e confere a posição final.

**VERIFICAR:** como mover o jogador no MP do B42 sem disparar o anti-cheat de movimento, e o carregamento da área no destino. Viabilidade: **M**.

Por que custa moedas: é um dreno de moedas que dá valor ao dinheiro sobrando no fim do jogo e evita teleporte como "botão de fuga" grátis.

---

## 3. Visão de dificuldade por igreja

| Igreja | Ondas (nível por minuto) | Duração | Zumbis gerados, 1 jogador | Corredores | Especiais novos |
| --- | --- | --- | --- | --- | --- |
| 1 Rosewood | 1-2-3-4-5 | 5 min | 70 | 0% (5% no minuto 5) | Rastejante, Penitente |
| 2 March Ridge | 1-2-3-4-5 · pausa · 5-5-6 | 10 min | 140 | 10%, depois 25% | Gritador |
| 3 Muldraugh | 3-4-5 · pausa · 4-5-6-6 · pausa · 6-7-7-8 | 15 min | 266 | 25% | Couraçado (5%), Bomba |
| 4 West Point | 4-5-6 · pausa · 5-6-7-7 · pausa · 7-8-8-9 | 15 min | 310 | 30% | Brutamontes, Blindado de Choque, bandidos (se instalado) |
| 5 Louisville | igual à 4 + pausa + 9-9-10 | 20 min | 428 | 35% | O Bispo (chefe final) |

Pausa = 2 min de preparo. Fórmula de cada minuto: **zumbis = 4 × nível + 2** para 1 jogador.

---

## 4. Cerco

### 4.1 Iniciar

1. O cerco só começa com a **relíquia** da cidade colocada no altar. A de Rosewood vem na mochila do Kit do Peregrino (seção 11); da igreja 2 em diante, ela é achada na missão da seção 7.1.
2. **Votação:** quem ativa o altar abre uma votação de 30 s. O cerco começa se a maioria dos jogadores online a até 30 tiles do altar aceitar.
3. **Participantes:** todo jogador a até 30 tiles do altar no início entra na lista de participantes. Só eles ficam sujeitos à regra de morte do cerco.
4. **Preparo:** 60 s antes da primeira onda, com aviso na HUD.

### 4.2 Estados

`ocioso → votação → preparo → onda → pausa → onda ... → vitória` ou `→ derrota`.

O servidor controla os estados com relógio real. O `EveryOneMinute` do jogo é minuto de jogo (~2,5 s reais) e não serve para isso.

### 4.3 Alcance do spawn (refinado)

A proposta anterior era um anel de 50 a 90 tiles. Agora ela fica mais segura:

| Regra | Valor |
| --- | --- |
| Pontos de spawn | 6 a 10 **âncoras fixas por igreja**, escolhidas à mão no mapa (fim de rua, beco, estacionamento), gravadas em `defs/` |
| Distância das âncoras | 40 a 60 tiles do altar |
| Distância mínima de qualquer jogador | 25 tiles. Âncora mais perto que isso é pulada naquele lote |
| Espalhamento | Cada zumbi nasce a até 4 tiles da âncora, só em chão livre e externo |
| Lote | A cada 15 s, divididos entre 3 ou 4 âncoras sorteadas |
| Teto | 80 zumbis do cerco vivos ao mesmo tempo (configurável) |
| Destino | Cada zumbi recebe a porta da igreja como destino. Um som curto no altar (raio de 25 tiles) a cada 20 s puxa os perdidos |

Por que âncoras fixas em vez de um anel sorteado:
- **Nada de spawn na água, dentro de parede ou no telhado.** Quem desenha a igreja escolhe pontos bons.
- **A área continua carregada.** O servidor só simula zumbis perto de jogadores. A 40 a 60 tiles do altar, com o grupo dentro da igreja, os zumbis ficam na área carregada. Raio exato no B42 com chunks de 8×8: **VERIFICAR**.
- **Tempo de chegada controlado:** a 50 tiles, um zumbi lento leva 45 a 90 s, e um corredor leva 10 a 15 s.
- **Som curto e não global:** um som alto puxaria os zumbis naturais da cidade inteira e deixaria a onda imprevisível. Os zumbis da cidade que vierem mesmo assim são bônus de moedas.

### 4.4 Multiplayer

- Zumbis por minuto × (1 + 0,75 × (participantes vivos − 1)). Com 4 jogadores, 3,25 vezes mais.
- O teto de 80 vivos vale para o cerco inteiro, não por jogador.

### 4.5 Vitória

1. O timer zera com pelo menos 1 participante vivo.
2. A igreja vira conquistada para o servidor inteiro: ícone no mapa, ponto de nascimento, teleporte e catálogo novo.
3. Cada participante vivo recebe a recompensa uma vez (idempotente) e entra no sorteio de buffs.
4. Os zumbis que sobraram continuam no mundo.

### 4.6 Morte e derrota

1. Um participante que morre perde tudo: itens, moedas da carteira e buffs. O corpo é esvaziado pelo servidor (proposta).
2. O personagem novo fica numa **sala de espera** trancada até o cerco acabar.
3. Quando o cerco termina, por vitória ou por derrota, os da sala de espera vão para o ponto de nascimento.
4. **Derrota:** todos os participantes morreram. A igreja continua não conquistada, a relíquia volta para o altar e uma nova tentativa só pode começar depois de 1 dia de jogo.
5. Quem não é participante e morre longe do cerco renasce normalmente.

---

## 5. Zumbis

### 5.1 O que a pesquisa encontrou

| Projeto | O que é | B42 / MP | Licença | Uso no church_run |
| --- | --- | --- | --- | --- |
| [Special Zombies Framework (B42)](https://steamcommunity.com/sharedfiles/filedetails/?id=3783282009), de OO | Base para zumbis especiais, com sincronização pelo servidor | B42.20.2. MP anunciado, mas comentários relatam instabilidade em servidor dedicado | Não informada | Inspiração. Pode ser dependência opcional, mas o código não pode ser copiado |
| [Screamer](https://steamcommunity.com/sharedfiles/filedetails/?id=3783282817), da mesma série | Vê o jogador a ~10 tiles, para, carrega e grita, atraindo zumbis a ~30 tiles. Bater nela durante a carga cancela o grito | B42.20.2 | Não informada | Base do nosso Gritador |
| [Spitter](https://steamcommunity.com/sharedfiles/filedetails/?id=3783283061) | Cospe ácido a até ~6 tiles, poça de 2×2 por ~3 s que deixa 30% mais lento e fere | B42.20.2 | Não informada | Base do nosso Cuspidor |
| [Tank](https://steamcommunity.com/sharedfiles/filedetails/?id=3783283328) | Vida altíssima, lento, entra em fúria e corre quando a vida cai abaixo de 15% a 40%, resiste a contundentes, fraco a lâminas longas, não cai com empurrão | B42.20.2. O autor admitiu que o MP ainda não estava pronto | Não informada | Base do nosso Brutamontes |
| [Bloater](https://steamcommunity.com/sharedfiles/filedetails/?id=3789467089) | Ao morrer, solta uma nuvem tóxica que causa dano, dor e enjoo. Máscara de gás protege | B42.20.2, com relatos de erros no MP | Não informada | Base da nossa Bomba |
| [Zomboid Forge](https://github.com/SirDoggyJvla/Zomboid-Forge), de SirDoggyJvla | Framework de zumbis customizados | Repositório marcado B41 | GPL-3.0 | Referência técnica de vida e tipos |
| [Bandits NPC](https://steamcommunity.com/sharedfiles/filedetails/?id=3268487204), de Slayer | NPCs bandidos | B42.20+, single e multiplayer | Direitos reservados, sem reupload | Dependência opcional, por adaptador |

Conclusão: não achei, nem no GitHub nem na Oficina, uma base aberta e estável no MP do B42 para reaproveitar. Os mods de OO provam que as mecânicas são possíveis no B42.20, mas não têm licença e ainda têm bugs no MP. **Recomendo implementar nossas próprias versões simples**, com as alavancas abaixo.

### 5.2 O que o Lua do B42 deixa mexer num zumbi

| Alavanca | Uso | Viab. |
| --- | --- | --- |
| Roupa (outfit) | Identidade visual: padre, choque, hazmat, militar, presidiário | F |
| Velocidade por zumbi | Corredor ou lento | M (VERIFICAR) |
| Vida | Mais resistente | M (vida alta tem bugs no MP, segundo o changelog do Zomboid Forge) |
| Dano recebido por tipo de arma | Fraqueza ou resistência | M |
| Parte do corpo atingida | Regra de tiro na cabeça | D (VERIFICAR com o tiro novo do B42) |
| Derrubar ou atordoar | Pulsos, explosões, imunidade a queda | M |
| Som no mundo | Grito, sino | F |
| Efeito na morte | Nuvem, explosão, item extra, zumbis extras | M |
| Efeito no jogador perto | Enjoo, dor, pânico, lentidão | M |
| Modelo 3D novo | Visual totalmente novo | D (Blender e pipeline de modelos do B42) |
| Textura nova numa roupa | Visual diferente sem modelo novo | M (arte CC0 ou CC-BY) |

### 5.3 Catálogo de zumbis especiais

| # | Zumbi | Ideia | Como fazer | Viab. | Igreja |
| --- | --- | --- | --- | --- | --- |
| 1 | Corredor | Corre como os corredores do jogo | Velocidade por zumbi no spawn | M | 2+ |
| 2 | Rastejante | Nasce rastejando no mato perto da igreja e morde o tornozelo | Spawn já caído sem pernas (VERIFICAR) | M | 1+ |
| 3 | Penitente | Zumbi de batina, lento, vale 5 moedas | Roupa de padre (confirmar outfit) + bônus de moeda | F | 1+ |
| 4 | Gritador | Ao ver um jogador a 10 tiles, para por 2 s e grita, chamando zumbis a 30 tiles. Bater nele cancela | Checagem de alvo só nos especiais + som no mundo | M | 2+ |
| 5 | Couraçado (sua ideia) | Usa capacete de choque. O 1º tiro na cabeça arranca o capacete, que cai no chão, e o 2º mata. No corpo, aguenta cerca de 8 tiros de pistola | Vida alta + contador de tiros na cabeça. Plano B, se a parte do corpo não for confiável: só vida alta | M/D | 3+ |
| 6 | Bomba | Roupa hazmat. Ao morrer, solta uma nuvem: quem está a até 3 tiles sente enjoo e perde fôlego. Máscara de gás protege | Efeito na morte + checagem de máscara. Nuvem visível: VERIFICAR efeito disponível | M | 3+ |
| 7 | Sineiro | Ao morrer, toca um sino e 6 zumbis extras surgem nas âncoras | Efeito na morte + gerador do cerco | F | 3+ |
| 8 | Mochileiro | 5% dos zumbis do cerco levam mochila com munição ou remédio | Item extra no corpo | F | 1+ |
| 9 | Brutamontes | Vida muito alta, lento, não cai com empurrão, resiste a contundentes, fraco a lâminas longas. Abaixo de 30% de vida, entra em fúria e corre | Vida + dano por tipo de arma + imunidade a queda + troca de velocidade | M/D | 4+ |
| 10 | Blindado de Choque | Roupa de choque da polícia. Golpes de frente causam metade do dano; pelas costas, dano normal | Compara a direção do zumbi com a do atacante | M | 4+ |
| 11 | Cuspidor | Cospe ácido a até 6 tiles, deixando uma poça que fere e deixa lento | Ataque à distância + área no chão. O visual da poça é o mais difícil | D | expansão |
| 12 | Espreitador | Fica agachado e parado, e só avança quando o jogador chega a 5 tiles | Controle de comportamento da IA | D | expansão |
| 13 | O Bispo (chefe) | Chefe final de Louisville: vida altíssima, não cai, e a cada 30 s chama 4 zumbis em volta dele. Matá-lo encerra a última onda com vitória | Vida + imunidade a queda + gerador do cerco | M | 5 |
| 14 | Bandidos | NPCs armados | Mod Bandits NPC, se instalado | M | 4+ |

**Ordem sugerida de construção:** Corredor e Penitente, depois Gritador e Sineiro, depois Couraçado (protótipo), Bomba, Brutamontes e Bispo. Cuspidor e Espreitador ficam para a expansão.

### 5.4 Verificação de movimento, animação e assets (2026-10-26)

**Nenhum zumbi foi testado no jogo ainda.** O que foi verificado é se existe prova de que algo igual já funciona no B42, e de que assets cada um precisa.

**O ponto principal:** nenhum especial é uma criatura nova. Todos são zumbis vanilla modificados, então andam, fazem rota, quebram barricadas, pulam cercas e atacam com a IA e as animações do próprio jogo. O código novo só acrescenta comportamento por cima: vida, velocidade, som, efeito na morte. Só o Cuspidor e o Espreitador precisariam de animação nova.

| # | Zumbi | Movimento e animação | Prova de que funciona no B42 | Asset extra | Situação |
| --- | --- | --- | --- | --- | --- |
| 1 | Corredor | Vanilla (corrida) | Velocidade aleatória com % de corredores no sandbox; o Tank de OO troca a velocidade de um zumbi para corredor no B42.20 | Nenhum | Comprovado por outro mod |
| 2 | Rastejante | Vanilla (rastejar) | Rastejantes existem no jogo base; nascer já rastejando não tem prova | Nenhum | Provável, VERIFICAR |
| 3 | Penitente | Vanilla | Roupa de padre (nome do outfit a confirmar) + bônus de moeda, que é só lógica nossa | Nenhum | Provável |
| 4 | Gritador | Vanilla para andar; a "carga" do grito reaproveita uma animação parada ou de atordoamento | Screamer de OO faz o mesmo no B42.20 | Som de grito CC0 | Comprovado por outro mod |
| 5 | Couraçado | Vanilla | Vida alta comprovada pelo Tank de OO. Tiro na cabeça: sem prova | Nenhum (capacete de choque é vanilla) | Incerto: depende da prova técnica de tiro na cabeça |
| 6 | Bomba | Vanilla | Bloater de OO faz nuvem tóxica no B42.20 | Visual da nuvem: efeito do jogo ou textura CC0 | Comprovado por outro mod; o visual é o risco |
| 7 | Sineiro | Vanilla | Só usa o nosso gerador de zumbis | Som de sino CC0 | Provável |
| 8 | Mochileiro | Vanilla | Zumbis vanilla já usam mochila | Nenhum | Comprovado no jogo base |
| 9 | Brutamontes | Vanilla. Não dá para aumentar o corpo de forma confiável por Lua (comentário do autor do Tank) | Tank de OO: vida, fúria, resistência por arma, imune a empurrão | Nenhum (diferenciar pela roupa, não pelo tamanho) | Comprovado por outro mod |
| 10 | Blindado de Choque | Vanilla | Dano por tipo de arma comprovado pelo Tank; regra de frente e costas sem prova | Nenhum (roupa de choque vanilla) | Provável |
| 11 | Cuspidor | **Precisa de animação de cuspe** (ou reaproveitar o ataque) e de visual da poça | Spitter de OO faz isso no B42.20 | Animação + textura da poça | Difícil |
| 12 | Espreitador | **Precisa de animação de agachar ou espreitar** e de IA nova | Nenhuma prova encontrada | Animação | Difícil, sem prova |
| 13 | O Bispo | Vanilla | Vida alta (Tank) + nosso gerador | Nenhum (roupa de padre) | Provável |
| 14 | Bandidos | Do próprio mod Bandits NPC | Bandits NPC roda no B42.20+ em single e multiplayer | Do mod | Comprovado, como dependência opcional |

**Animações e modelos: o que é gratuito e pode entrar num mod de código aberto**

| Recurso | O que é | Licença | Serve? |
| --- | --- | --- | --- |
| [AnimForge](https://github.com/AlexVDefi/AnimForge) | Editor de animação dentro do B42: posa ossos, exporta `.x` e gera o XML de AnimSet | Código MIT, mas inclui um patch de classes Java do jogo, que não é MIT | Sim, como **ferramenta de desenvolvimento** no PC de quem cria a animação. O patch não vai para dentro do church_run, que continua Lua puro |
| [Quaternius Universal Animation Library](https://quaternius.com/packs/universalanimationlibrary.html) e [volume 2](https://opengameart.org/content/universal-animation-library-2) | 120+ e 130+ animações humanoides; o volume 2 cita locomoção de zumbi | CC0 | Sim, mas precisa ser readaptada (retarget) no Blender para o esqueleto do PZ. Trabalho manual médio a difícil |
| Mixamo (Adobe) | Animações prontas | Uso em jogos liberado, mas é proibido distribuir os arquivos brutos ([FAQ](https://community.adobe.com/questions-696/mixamo-faq-licensing-royalties-ownership-eula-and-tos-589400)) | **Não.** Um repositório aberto distribuiria os arquivos brutos |
| [AoM ZED Animations B42](https://steamcommunity.com/sharedfiles/filedetails/?id=2590814089) | Animações de zumbi feitas à mão, adaptadas ao B42 | Sem licença informada | Só prova de que animação nova de zumbi funciona no B42. Não pode ser copiada |
| Sons e texturas CC0 (ex.: freesound.org com filtro CC0, Poly Haven, ambientCG) | Grito, sino, textura de poça | CC0, conferir arquivo por arquivo | Sim |

**Conclusão:** 12 dos 14 zumbis usam movimento e animação que já existem (do jogo base ou, no caso dos bandidos, do próprio mod). Para eles, o risco não está no movimento: está em 4 provas técnicas de código (velocidade por zumbi, vida alta no MP, tiro na cabeça e efeitos sincronizados). Só o Cuspidor e o Espreitador dependem de animação nova, e por isso continuam na expansão.

---

## 6. Economia

### 6.1 Moedas

- **Todo zumbi vale 1 moeda** (decidido). Penitente vale 5.
- **Recomendado: carteira virtual no servidor.** A moeda vai direto para o saldo de quem deu o último golpe, sem item no chão. Vantagens:
  - Ninguém precisa revistar 300 corpos depois de um cerco.
  - Não existe moeda para duplicar, roubar ou perder em corpo queimado.
  - O servidor é a única fonte da verdade (CLAUDE.md, princípio 1).
  - O saldo aparece na HUD, e "perder tudo ao morrer" continua valendo: a carteira zera.
- Moedas podem ser passadas entre jogadores no altar (transferência registrada no log).
- Zumbi morto por fogo, carro sem motorista ou queda não dá moeda. Atribuição do abate no MP: **VERIFICAR**.
- Alternativa, se preferir algo físico: moeda como item no corpo. Ela funciona, mas traz os problemas acima.

### 6.2 Modelo de renda (1 jogador)

| Etapa | Renda fora do cerco | Moedas do cerco (75% dos zumbis mortos) | Acumulado na etapa (~3 h de jogo) |
| --- | --- | --- | --- |
| Antes da igreja 1 | ~40/h | — | ~80 (2 h) |
| Depois da igreja 1 | ~60/h | ~53 | ~235 |
| Depois da igreja 2 | ~80/h | ~105 | ~345 |
| Depois da igreja 3 | ~100/h | ~200 | ~500 |
| Depois da igreja 4 | ~120/h | ~233 | ~590 |

As rendas por hora são estimativas para calibrar no playtest. Se a renda real for bem maior, o ajuste é um multiplicador de preços nas opções de sandbox, e não item a item.

### 6.3 Princípios de preço

1. A arma principal de cada etapa custa entre 40% e 90% do que o jogador junta naquela etapa. Dá para comprar uma coisa grande, não tudo.
2. A bala custa entre 0,4 e 0,8 moeda. Atirar rende um pouco mais do que custa, e o preço real da arma de fogo é o barulho.
3. Remédio básico é barato (5 a 15). Remédio que salva a vida (antibiótico, sutura) custa como meia arma barata.
4. Proteção sobe em degraus: civil (20 a 80), policial (50 a 140), militar e metal (120 a 260).
5. Não existe venda para a loja. Moeda só vem de zumbi e de missão.

### 6.4 Resumo dos preços

Tabela completa com IDs em [lojas.md](lojas.md).

| Etapa | Arma principal | Munição (caixa) | Proteção | Remédio |
| --- | --- | --- | --- | --- |
| Loja Básica | Taco 25, pé de cabra 40 | — | — | Bandagem 5, desinfetante 15 |
| Igreja 1 | M9 90, JS-2000 160, MSR700 200 | 20 a 24 | Colete civil 80 | Tala 15 |
| Igreja 2 | M1911 120, Patrol 140, cano duplo 180, machado 110 | 20 a 30 | Colete policial 140 | Antibióticos 45 |
| Igreja 3 | MSR788 300, M16 480, JS-3T 380, katana 320 | 30 a 32 | Colete militar 260, capacete antimotim 180 | Kit do mod 90 |
| Igrejas 4 e 5 | Mesmo catálogo, com 10% e 20% de desconto | | | |

### 6.5 Drenos de moedas

| Dreno | Preço |
| --- | --- |
| Teleporte | 10 por salto |
| Conserto de arma no altar | 20% do preço de loja da arma |
| Reroll extra de buff | 15 × número da igreja |
| Morte | Perde a carteira inteira |

---

## 7. Missões: dar objetivo ao jogo

O church_run nasceu como gerador de missões. A conquista das igrejas é a campanha principal, montada com os mesmos tipos de objetivo do motor previsto no CLAUDE.md: `visit`, `collect`, `deliver`, `kill` e `survive`. Isso dá ao jogo um objetivo claro sem tirar a liberdade.

### 7.1 Campanha: um ato por cidade

| Passo | Missão | Tipo de objetivo | Recompensa |
| --- | --- | --- | --- |
| 1 | **Peregrinação:** chegar à igreja da cidade. O ícone "?" dela aparece no mapa quando a anterior é conquistada | `visit` | 20 × N moedas |
| 2 | **Relíquia** (da igreja 2 em diante; a de Rosewood vem no Kit do Peregrino): o servidor esconde a relíquia da cidade num contêiner de um prédio sorteado. O mapa marca um círculo de 60 tiles | `collect` (item do mod) | Libera o altar |
| 3 | **Preparação (opcional):** entregar 20 tábuas e 1 caixa de pregos no altar | `deliver` | +60 s de preparo e +1 âncora pulada na 1ª onda |
| 4 | **Cerco:** sobreviver às ondas | `survive` | Conquista, buffs e 50 × N moedas |

N = número da igreja. Entre West Point e Louisville há um passo extra: **Abrir caminho por Valley Station** (`kill` numa área marcada, 40 zumbis).

### 7.2 Contratos repetíveis (mural da igreja)

Toda igreja conquistada tem um mural com 3 contratos por dia de jogo, os mesmos para o servidor inteiro. Qualquer jogador pode aceitar.

| Contrato | O que pede | Tipo | Recompensa | Viab. |
| --- | --- | --- | --- | --- |
| Caçada | Matar 25 zumbis num bairro marcado | `kill` em área | 30 | F |
| Abate especial | Matar um especial marcado no mapa (ex.: Gritador) | `kill` de especial | 40 | M |
| Suprimentos | Entregar 8 latas de comida no altar | `deliver` | 35 | F |
| Exploração | Visitar o posto policial, o hospital e a loja de armas da cidade | `visit` (3 pontos) | 30 | F |
| Resgate de carga | Uma caixa de suprimentos aparece num ponto cercado por 15 zumbis | `visit` + `collect` | Itens da caixa | M |
| Limpeza de prédio | Matar todos os zumbis dentro de um prédio marcado | novo: `clear_building` | 40 | M |
| Vigília | Mini-cerco de 3 min numa igreja já conquistada | `survive` | 60 + 1 ficha de reroll | F (reaproveita o cerco) |
| Reparo | Barricar 6 janelas da igreja | novo: `barricade` | 30 | M |

### 7.3 Eventos do mundo (opcionais, sandbox)

- **Contra-ataque:** a cada 3 a 5 dias de jogo, uma igreja conquistada pode ser atacada, com aviso 10 min antes. Se ninguém defender, a loja dela fecha por 1 dia de jogo. A conquista nunca é perdida.
- **Fim de campanha:** depois de Louisville, o **Modo Peregrino** libera cercos repetíveis em todas as igrejas com dificuldade +1 por volta, para o servidor continuar tendo objetivo.

---

## 8. Buffs

Regras e lista completa em [buffs.md](buffs.md). Resumo:

- Oferta de 3, só o escolhido sai da lista, perdidos na morte.
- Escolhas por igreja: 1, 2, 2, 3, 3.
- 1 reroll grátis por oferta. Reroll extra custa 15 × N moedas.
- Fichas de reroll também saem do contrato Vigília.
- Faltam os 30 finais, escolhidos entre os 81 candidatos.

---

## 9. Interface

| Elemento | O que mostra | Viab. |
| --- | --- | --- |
| HUD à esquerda | Carteira, estado do cerco (onda, tempo, zumbis restantes), buffs ativos com recarga, missão atual | F |
| Ícones no mapa | Igreja conquistada (cruz), próxima igreja ("?"), círculo da relíquia, alvos de contrato | M (VERIFICAR API de símbolos do mapa no B42) |
| Janela do altar | Abas: Loja (5 categorias), Serviços, Teleporte, Mural, Placar | F |
| Votação | Pop-up de 30 s para iniciar o cerco | F |
| Placar | Abates, moedas, cercos, mortes por jogador | F |

---

## 10. Opções de sandbox (configuráveis pelo admin)

Tudo que é número de balanceamento vira opção, porque um mod aberto vai rodar em servidores com gostos diferentes.

| Opção | Padrão |
| --- | --- |
| Multiplicador de zumbis por onda | 1,0 |
| Teto de zumbis do cerco vivos | 80 |
| Distância mínima de spawn até jogador | 25 tiles |
| Moedas por zumbi comum | 1 |
| Multiplicador de preços | 1,0 |
| Custo e recarga do teleporte | 10 moedas, 5 min |
| Esvaziar o corpo na morte | Sim |
| Sala de espera durante o cerco | Sim |
| Contra-ataques | Desligado |
| Bandidos (se o mod estiver instalado) | Ligado a partir da igreja 4 |

---

## 11. Outras melhorias propostas

1. **Kit do Peregrino** (decidido; entra na Fase 1): todo personagem novo nasce com uma mochila básica com taco e 3 bandagens, mais 30 moedas. Enquanto Rosewood não for conquistada, a mochila traz também a relíquia de Rosewood. Quem entra num servidor com 3 igrejas já conquistadas não fica inútil.
2. **Votação e participantes no cerco** (seção 4.1), para que um jogador não prenda os outros na regra de morte sem querer.
3. **Carteira virtual** (seção 6.1).
4. **Placar** no altar, para competição amigável no grupo.
5. **Modo Peregrino** depois da campanha (seção 7.3).
6. **Tudo em sandbox** (seção 10).

---

## 12. Riscos técnicos (VERIFICAR antes das specs)

| Risco | Afeta | Plano B |
| --- | --- | --- |
| Teleporte no MP do B42 e anti-cheat de movimento | Teleporte, nascimento, sala de espera | Teleporte só com o jogador parado e com conferência da posição; se falhar, nascimento comum + mapa |
| Raio da área carregada no MP (chunks de 8×8) | Âncoras de spawn | Âncoras mais perto (30 a 45 tiles) |
| Atribuição do abate no MP | Carteira | Moeda física no corpo |
| Parte do corpo atingida pelo tiro novo | Couraçado, Olho Morto | Só vida alta |
| Vida alta de zumbi no MP | Couraçado, Brutamontes, Bispo | Vida moderada + resistência por tipo de arma |
| Velocidade por zumbi | Corredores | Sandbox com % de corredores no mundo todo |
| Sincronizar queda e atordoamento de zumbis | Onda de Choque, Bomba, buffs | Efeitos só de dano |
| Nomes de outfits e roupas no B42.20 | Lojas, especiais | Conferir no `clothing.txt` |
| Símbolos no mapa pelo Lua | Ícones | Lista de igrejas na janela do altar |

---

## 13. Specs a escrever (atualizado)

| Fase | Specs |
| --- | --- |
| Base | SPEC-001 Protocolo, SPEC-002 Persistência, ADR-002 Progressão global, ADR-003 Licença e dependências |
| Mundo | SPEC-010 Igrejas e âncoras, SPEC-011 Nascimento por progresso, SPEC-012 Teleporte |
| Cerco | SPEC-020 Estados e votação, SPEC-021 Gerador de zumbis, SPEC-022 Tabela de ondas, SPEC-030 Morte e sala de espera |
| Economia | SPEC-040 Carteira e moedas, SPEC-041 Lojas, SPEC-043 Serviços (conserto, reroll extra) |
| Buffs | SPEC-050 Sorteio e reroll, SPEC-051 Catálogo |
| Missões | SPEC-080 Campanha (atos), SPEC-081 Mural de contratos, SPEC-082 Eventos |
| Interface | SPEC-060 HUD, SPEC-061 Mapa, SPEC-062 Janela do altar |
| Zumbis | SPEC-070 Base de especiais, uma spec por zumbi a partir da SPEC-071, SPEC-079 Bandidos opcionais |

**Primeira fatia jogável:** Base + Mundo (sem teleporte) + Kit do Peregrino com a relíquia + Cerco, com Rosewood (Fase 1 do ROADMAP). A carteira vem logo depois, na Fase 2, e fecha o ciclo "juntar moedas → cercar → vencer". Decidido em 26/10/2026 pela regra do `GUIA-CLAUDE.md` §6.1: o ROADMAP manda no "quando".

---

## 14. Decisões em aberto

1. Aprovar a cadeia Rosewood → March Ridge → Muldraugh → West Point → Louisville.
2. Carteira virtual (recomendado) ou moeda física no corpo.
3. Teleporte a 10 moedas com recarga de 5 min.
4. Descontos de 10% e 20% nas igrejas 4 e 5.
5. Esvaziar o corpo do morto.
6. Contra-ataques às igrejas: ligados ou desligados por padrão.
7. O Bispo como chefe final.
8. Os 30 buffs finais.
9. Campanha por cidade (peregrinação e preparação) e mural de contratos: entram na v1 ou ficam para depois da 1.0? A relíquia já está decidida: vem no Kit do Peregrino em Rosewood e é achada da igreja 2 em diante (seção 1.2). O ROADMAP deixa o resto da campanha no fim da Fase 5 e o mural depois da 1.0.

---

## 15. Fontes

- [Knox Country Map Guide (pzfans)](https://pzfans.com/knox_country_breakdown_zomboids_map_survival_uncovered/): cidades, posição e distâncias.
- [Lista de IDs do B42 (gameserverkings)](https://www.gameserverkings.com/knowledge-base/project-zomboid/project-zomboid-item-ids/) e [armas do B42 (pzfans)](https://pzfans.com/item-weapons/).
- [Roupas do B42.20.4 (bamboogaming)](https://www.bamboogaming.net/project-zomboid/clothing).
- [Velocidade de zumbis no B42 (pzfans)](https://pzfans.com/shamblers-fast-shamblers-sprinters-and-customize-zombie-speed).
- Série Special Zombies de OO: [Framework](https://steamcommunity.com/sharedfiles/filedetails/?id=3783282009), [Screamer](https://steamcommunity.com/sharedfiles/filedetails/?id=3783282817), [Spitter](https://steamcommunity.com/sharedfiles/filedetails/?id=3783283061), [Tank](https://steamcommunity.com/sharedfiles/filedetails/?id=3783283328), [Bloater](https://steamcommunity.com/sharedfiles/filedetails/?id=3789467089).
- [Zomboid Forge (GitHub)](https://github.com/SirDoggyJvla/Zomboid-Forge) e [Bandits NPC](https://steamcommunity.com/sharedfiles/filedetails/?id=3268487204).
- [Política de modding da The Indie Stone](https://projectzomboid.com/blog/modding-policy/).
- [Perks do CoD Zombies (dotesports)](https://dotesports.com/call-of-duty/news/all-perk-a-colas-in-black-ops-6-zombies-all-zombies-perks-explained), inspiração dos buffs.
