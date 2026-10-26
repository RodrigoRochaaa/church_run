# church_run: catálogo das lojas por igreja (rascunho)

Status: rascunho, base para a SPEC-041 (lojas e catálogo por igreja).
Atualizado em: 2026-10-26.
Alvo: Project Zomboid Build 42.20+, multiplayer, servidor autoritativo.

---

## 1. Regras

1. **Catálogo cumulativo.** A loja da igreja N vende tudo das igrejas 1 a N, mais os itens novos de N.
2. **Catálogo completo na Igreja 3.** Como combinado, as igrejas 4 e 5 não trazem itens novos. O que muda nelas é a dificuldade e as recompensas. Uma opção para pensar está na seção 5.
3. **Lojas abertas por igreja vencida.** O jogador compra em qualquer igreja já conquistada pelo servidor. O catálogo é o da igreja mais alta vencida.
4. **5 categorias, uma aba cada:** Armas, Defesa (proteção), Roupas, Remédios e Barricadas.
5. **Preço fixo por item,** igual em todas as igrejas. O buff #41 Fiel da Casa dá −15%.
6. **Compra validada no servidor:** ele confere o saldo de moedas, desconta, entrega o item e grava no log (tudo-ou-nada, como manda o CLAUDE.md).
7. **IDs de itens validados na carga do servidor.** Um ID inexistente desativa só aquele item, com log, sem derrubar o mod (CLAUDE.md 3.4).

## 2. Economia de referência

Hoje cada zumbi do cerco dá 1 moeda. Fora do cerco, a proposta (ainda não decidida) é 20% de chance.

| Igreja | Moedas por cerco, 1 jogador (aprox.) |
| --- | --- |
| 1 | 70 |
| 2 | 140 |
| 3 | 266 |
| 4 | 310 |
| 5 | ~400 |

Princípio dos preços: **a arma principal de cada igreja custa mais ou menos um cerco inteiro daquela igreja.** Munição e remédio custam pouco o bastante para o jogador gastar a cada cerco, e caro o bastante para ele não estocar.

## 3. Catálogo

IDs de armas, munição, remédio e construção conferidos na lista do B42.20 ([gameserverkings](https://www.gameserverkings.com/knowledge-base/project-zomboid/project-zomboid-item-ids/), [pzfans](https://pzfans.com/item-weapons/)). Os de roupas e proteção são os prováveis, com nome conferido no B42.20.4 ([bamboogaming](https://www.bamboogaming.net/project-zomboid/clothing)); os marcados com **(confirmar)** precisam ser conferidos no `clothing.txt` do jogo.

### Igreja 1 · Rosewood (itens base)

**Armas**

| Item | ID | Preço |
| --- | --- | --- |
| Pistola M9 | `Base.Pistol` | 60 |
| Pente de M9 | `Base.9mmClip` | 15 |
| Caixa de munição 9 mm | `Base.Bullets9mmBox` | 12 |
| Espingarda JS-2000 | `Base.Shotgun` | 110 |
| Caixa de cartuchos 12 | `Base.ShotgunShellsBox` | 18 |
| Rifle MSR700 (o mais fraco) | `Base.VarmintRifle` | 140 |
| Caixa de munição 5,56 mm | `Base.556Box` | 22 |
| Taco de beisebol | `Base.BaseballBat` | 15 |
| Pé de cabra | `Base.Crowbar` | 25 |

**Defesa**

| Item | ID | Preço |
| --- | --- | --- |
| Colete à prova de balas civil | `Base.Vest_BulletCivilian` (confirmar) | 50 |
| Capacete de bicicleta | `Base.Hat_BicycleHelmet` (confirmar) | 15 |
| Caneleira | `Base.ShinGuard_L` / `_R` (confirmar) | 20 |

**Roupas**

| Item | ID | Preço |
| --- | --- | --- |
| Jaqueta acolchoada | `Base.Jacket_Padded` (confirmar) | 35 |
| Calça acolchoada | `Base.Trousers_Padded` (confirmar) | 30 |
| Luvas de couro | `Base.Gloves_LeatherGloves` (confirmar) | 15 |

**Remédios**

| Item | ID | Preço |
| --- | --- | --- |
| Bandagem | `Base.Bandage` | 4 |
| Desinfetante | `Base.Disinfectant` | 8 |
| Analgésico | `Base.Pills` | 8 |
| Tala | `Base.Splint` | 10 |

**Barricadas**

| Item | ID | Preço |
| --- | --- | --- |
| Tábua | `Base.Plank` | 3 |
| Caixa de pregos | `Base.NailsBox` | 10 |
| Martelo | `Base.Hammer` | 15 |
| Serrote | `Base.GardenSaw` | 15 |

### Igreja 2 · Riverside (acrescenta)

**Armas**

| Item | ID | Preço |
| --- | --- | --- |
| Pistola M1911 | `Base.Pistol2` | 90 |
| Pente de M1911 | `Base.45Clip` | 18 |
| Caixa de munição .45 | `Base.Bullets45Box` | 15 |
| Revólver Patrol (.357) | `Base.Revolver` | 100 |
| Caixa de munição .357 | `Base.Bullets357Box` | 18 |
| Espingarda de cano duplo | `Base.DoubleBarrelShotgun` | 130 |
| Machado de bombeiro | `Base.Axe` | 70 |
| Machete | `Base.Machete` | 80 |
| Taco de metal | `Base.BaseballBat_Metal` | 40 |

**Defesa**

| Item | ID | Preço |
| --- | --- | --- |
| Colete à prova de balas policial | `Base.Vest_BulletPolice` (confirmar) | 90 |
| Capacete de futebol americano | `Base.Hat_FootballHelmet` (confirmar) | 40 |
| Protetor de pescoço de couro | ID a confirmar (Leather Neck Guard) | 35 |

**Roupas**

| Item | ID | Preço |
| --- | --- | --- |
| Jaqueta de couro | `Base.Jacket_LeatherBlack` (confirmar) | 60 |
| Botas militares | `Base.Shoes_ArmyBoots` (confirmar) | 40 |

**Remédios**

| Item | ID | Preço |
| --- | --- | --- |
| Bandagem esterilizada | `Base.AlcoholBandage` | 8 |
| Antibióticos | `Base.Antibiotics` | 25 |
| Agulha de sutura | `Base.SutureNeedle` | 12 |
| Porta-agulha | `Base.SutureNeedleHolder` | 20 |

**Barricadas**

| Item | ID | Preço |
| --- | --- | --- |
| Chapa metálica pequena | `Base.SmallSheetMetal` | 12 |
| Barra de aço | `Base.MetalBar` | 10 |
| Serra de metal | `Base.Saw` | 20 |

### Igreja 3 · West Point (acrescenta e completa o catálogo)

**Armas**

| Item | ID | Preço |
| --- | --- | --- |
| Rifle MSR788 | `Base.HuntingRifle` | 230 |
| Caixa de munição .308 | `Base.308Box` | 30 |
| Pistola B-F (.44) | `Base.Pistol3` | 180 |
| Pente de B-F | `Base.44Clip` | 25 |
| Caixa de munição .44 | `Base.Bullets44Box` | 22 |
| Fuzil M16 | `Base.AssaultRifle` | 350 |
| Pente de M16 | `Base.556Clip` | 35 |
| Espingarda tática JS-3T | `Base.JS3T_Shotgun` | 260 |
| Katana | `Base.Katana` | 250 |

**Defesa**

| Item | ID | Preço |
| --- | --- | --- |
| Colete à prova de balas militar | `Base.Vest_BulletArmy` (confirmar) | 160 |
| Capacete antimotim | `Base.Hat_RiotHelmet` (confirmar) | 120 |
| Ombreira de metal articulada | ID a confirmar (Articulated Metal Shoulder Armor) | 90 |
| Caneleira de metal articulada | ID a confirmar (Articulated Metal Shin Armor) | 80 |
| Protetor de pescoço de metal | ID a confirmar (Metal Neck Guard) | 70 |

**Roupas**

| Item | ID | Preço |
| --- | --- | --- |
| Jaqueta de bombeiro | `Base.Jacket_Fireman` (confirmar) | 110 |
| Calça de bombeiro | `Base.Trousers_Fireman` (confirmar) | 90 |
| Jaqueta militar | `Base.Jacket_ArmyCamoGreen` (confirmar) | 80 |
| Calça militar | `Base.Trousers_ArmyService` (confirmar) | 70 |

**Remédios**

| Item | ID | Preço |
| --- | --- | --- |
| Pinça | `Base.Tweezers` (confirmar) | 15 |
| Lenços com álcool | `Base.AlcoholWipes` (confirmar) | 6 |
| Kit de primeiros socorros (pacote do mod: 4 bandagens esterilizadas, 1 desinfetante, 1 tala, 1 analgésico) | item próprio do mod | 60 |

**Barricadas**

| Item | ID | Preço |
| --- | --- | --- |
| Chapa metálica | `Base.SheetMetal` | 25 |
| Maçarico | `Base.BlowTorch` | 70 |
| Varetas de solda | `Base.WeldingRods` | 15 |
| Máscara de solda | `Base.WeldingMask` (confirmar) | 40 |
| Arame farpado | `Base.BarbedWire` (confirmar) | 20 |

### Igrejas 4 · Muldraugh e 5 · Louisville

Catálogo igual ao da Igreja 3. Nenhum item novo.

## 4. Totais por igreja

| Igreja | Itens novos | Catálogo acumulado |
| --- | --- | --- |
| 1 | 23 | 23 |
| 2 | 21 | 44 |
| 3 | 26 | 70 |
| 4 | 0 | 70 |
| 5 | 0 | 70 |

## 5. Pontos para decidir

1. **Igrejas 4 e 5 sem itens novos.** Pode faltar motivação para chegar à 5. Duas opções sem quebrar a regra: (a) a Igreja 4 desconta 10% e a 5 desconta 20% em toda a loja; (b) duas peças "relíquia", só para quem vencer a 5 (ex.: fuzil M1A `Base.AssaultRifle2` e uma armadura de placas). Recomendo (a).
2. **Munição pesa na economia.** Com 70 moedas na Igreja 1, comprar a pistola (60) deixa pouco para munição. Isso é intencional (preço alto), mas vale testar se o jogador consegue vencer a Igreja 2 só com o que comprou na 1.
3. **Estoque.** Hoje a loja é infinita. Dá para limitar a quantidade por cerco (ex.: 2 armas de fogo por jogador por cerco), se as armas ficarem fáceis demais de acumular no grupo.
4. **Itens marcados (confirmar):** antes de aprovar a spec, conferir cada ID no `media/scripts/generated/items/clothing.txt` do B42.20.
