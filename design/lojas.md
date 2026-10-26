# church_run: catálogo e preços das lojas (v0.2)

Status: rascunho, base para as specs SPEC-040 (moeda) e SPEC-041 (lojas).
Atualizado em: 2026-10-26. Substitui a v0.1 (preços e ordem das cidades mudaram).
Alvo: Project Zomboid Build 42.20+, multiplayer, servidor autoritativo.
Contexto completo: [church_run_gdd.md](church_run_gdd.md), seção 6 (economia).

---

## 1. Regras

1. **Todo zumbi dá 1 moeda**, dentro e fora do cerco (decidido). Recomendado: a moeda vai direto para a carteira virtual de quem matou (GDD, seção 6.1). Moedas só vêm de zumbis e de missões: não existe venda de itens para a loja.
2. **Loja Básica desde o início.** A igreja de Rosewood (igreja 1) abre com a Loja Básica antes de ser conquistada, para as moedas terem uso desde o primeiro dia.
3. **Catálogo cumulativo.** Vencer a igreja N libera o catálogo da igreja N, somado aos anteriores. O catálogo fica completo na igreja 3.
4. **Igrejas 4 e 5:** sem itens novos. Proposta: vencer a 4 dá 10% de desconto em tudo e vencer a 5 dá 20%.
5. **Comprar em qualquer igreja conquistada**, sempre com o catálogo mais alto já liberado no servidor.
6. **5 abas:** Armas, Defesa, Roupas, Remédios, Barricadas. Há também os Serviços da seção 4.
7. **Preço fixo por item.** O buff #41 Fiel da Casa dá −15%, somado ao desconto da igreja.
8. **Compra validada no servidor:** ele confere o saldo, desconta, entrega o item e grava no log, tudo-ou-nada.
9. **IDs validados na carga do servidor.** Um ID inexistente desativa só aquele item, com log.

## 2. Como os preços foram calculados

O modelo completo está no GDD. Resumo:

- Renda estimada de 1 jogador: cerca de 40 moedas por hora de jogo no começo, subindo até cerca de 120 com equipamento melhor, mais as moedas do cerco.
- Entre duas igrejas, um jogador solo junta cerca de 235 moedas (depois da igreja 1), 345 (depois da 2) e 500 (depois da 3).
- **Uma arma principal por etapa:** com o que junta, o jogador compra uma arma nova e o básico para o próximo cerco, mas não tudo. Escolher é parte do jogo.
- **Atirar deve render um pouco mais do que custa.** A bala custa entre 0,4 e 0,8 moeda, e um zumbi costuma levar 1 a 2 balas. Armas de fogo ficam mais ou menos neutras em moedas, e o custo real delas é o barulho, que atrai mais zumbis.
- Tamanho das caixas de munição assumido: 50 balas de pistola ou revólver, 24 cartuchos e 40 balas de fuzil. Se o B42 usar outro tamanho, o preço da caixa muda e o preço por bala fica o mesmo.

IDs de armas, munição, remédio e construção conferidos na lista do B42.20 ([gameserverkings](https://www.gameserverkings.com/knowledge-base/project-zomboid/project-zomboid-item-ids/), [pzfans](https://pzfans.com/item-weapons/)). Os de roupa e proteção são prováveis, com o nome conferido no B42.20.4 ([bamboogaming](https://www.bamboogaming.net/project-zomboid/clothing)). Os marcados **(confirmar)** precisam ser conferidos no `clothing.txt` do jogo.

---

## 3. Catálogo

### Loja Básica (aberta desde o início em Rosewood)

| Aba | Item | ID | Preço |
| --- | --- | --- | --- |
| Armas | Taco de beisebol | `Base.BaseballBat` | 25 |
| Armas | Pé de cabra | `Base.Crowbar` | 40 |
| Armas | Faca de caça | `Base.HuntingKnife` (confirmar) | 30 |
| Remédios | Bandagem | `Base.Bandage` | 5 |
| Remédios | Desinfetante | `Base.Disinfectant` | 15 |
| Remédios | Analgésico | `Base.Pills` | 10 |
| Barricadas | Tábua | `Base.Plank` | 4 |
| Barricadas | Caixa de pregos | `Base.NailsBox` | 15 |
| Barricadas | Martelo | `Base.Hammer` | 30 |

### Igreja 1 · Rosewood (acrescenta)

| Aba | Item | ID | Preço |
| --- | --- | --- | --- |
| Armas | Pistola M9 | `Base.Pistol` | 90 |
| Armas | Pente de M9 | `Base.9mmClip` | 20 |
| Armas | Caixa de 9 mm | `Base.Bullets9mmBox` | 20 |
| Armas | Revólver SN38 | `Base.Revolver_Short` | 70 |
| Armas | Caixa de .38 | `Base.Bullets38Box` | 20 |
| Armas | Espingarda JS-2000 | `Base.Shotgun` | 160 |
| Armas | Caixa de cartuchos 12 | `Base.ShotgunShellsBox` | 24 |
| Armas | Rifle MSR700 (o mais fraco) | `Base.VarmintRifle` | 200 |
| Armas | Caixa de 5,56 mm | `Base.556Box` | 20 |
| Defesa | Colete à prova de balas civil | `Base.Vest_BulletCivilian` (confirmar) | 80 |
| Defesa | Capacete de bicicleta | `Base.Hat_BicycleHelmet` (confirmar) | 20 |
| Defesa | Caneleira | ID a confirmar (Shin Guard) | 30 |
| Roupas | Jaqueta acolchoada | `Base.Jacket_Padded` (confirmar) | 50 |
| Roupas | Calça acolchoada | `Base.Trousers_Padded` (confirmar) | 45 |
| Roupas | Luvas de couro | `Base.Gloves_LeatherGloves` (confirmar) | 20 |
| Remédios | Tala | `Base.Splint` | 15 |
| Barricadas | Serrote | `Base.GardenSaw` | 30 |

### Igreja 2 · March Ridge (acrescenta)

| Aba | Item | ID | Preço |
| --- | --- | --- | --- |
| Armas | Pistola M1911 | `Base.Pistol2` | 120 |
| Armas | Pente de M1911 | `Base.45Clip` | 25 |
| Armas | Caixa de .45 | `Base.Bullets45Box` | 20 |
| Armas | Revólver Patrol (.357) | `Base.Revolver` | 140 |
| Armas | Caixa de .357 | `Base.Bullets357Box` | 30 |
| Armas | Espingarda de cano duplo | `Base.DoubleBarrelShotgun` | 180 |
| Armas | Machado de bombeiro | `Base.Axe` | 110 |
| Armas | Machete | `Base.Machete` | 120 |
| Armas | Taco de metal | `Base.BaseballBat_Metal` | 60 |
| Armas | Lança curta | `Base.SpearShort` | 70 |
| Defesa | Colete à prova de balas policial | `Base.Vest_BulletPolice` (confirmar) | 140 |
| Defesa | Capacete de futebol americano | `Base.Hat_FootballHelmet` (confirmar) | 60 |
| Defesa | Protetor de pescoço de couro | ID a confirmar (Leather Neck Guard) | 50 |
| Roupas | Jaqueta de couro | `Base.Jacket_LeatherBlack` (confirmar) | 80 |
| Roupas | Botas militares | `Base.Shoes_ArmyBoots` (confirmar) | 60 |
| Remédios | Bandagem esterilizada | `Base.AlcoholBandage` | 12 |
| Remédios | Antibióticos | `Base.Antibiotics` | 45 |
| Remédios | Agulha de sutura | `Base.SutureNeedle` | 15 |
| Remédios | Porta-agulha | `Base.SutureNeedleHolder` | 30 |
| Barricadas | Chapa metálica pequena | `Base.SmallSheetMetal` | 25 |
| Barricadas | Barra de aço | `Base.MetalBar` | 15 |
| Barricadas | Serra de metal | `Base.Saw` | 35 |

### Igreja 3 · Muldraugh (acrescenta e completa o catálogo)

| Aba | Item | ID | Preço |
| --- | --- | --- | --- |
| Armas | Rifle MSR788 | `Base.HuntingRifle` | 300 |
| Armas | Caixa de .308 | `Base.308Box` | 32 |
| Armas | Pistola B-F (.44) | `Base.Pistol3` | 260 |
| Armas | Pente de B-F | `Base.44Clip` | 30 |
| Armas | Caixa de .44 | `Base.Bullets44Box` | 30 |
| Armas | Revólver Magnum (.44) | `Base.Revolver_Long` | 280 |
| Armas | Fuzil M16 | `Base.AssaultRifle` | 480 |
| Armas | Pente de M16 | `Base.556Clip` | 40 |
| Armas | Espingarda tática JS-3T | `Base.JS3T_Shotgun` | 380 |
| Armas | Katana | `Base.Katana` | 320 |
| Defesa | Colete à prova de balas militar | `Base.Vest_BulletArmy` (confirmar) | 260 |
| Defesa | Capacete antimotim | `Base.Hat_RiotHelmet` (confirmar) | 180 |
| Defesa | Ombreira de metal articulada | ID a confirmar (Articulated Metal Shoulder Armor) | 150 |
| Defesa | Caneleira de metal articulada | ID a confirmar (Articulated Metal Shin Armor) | 140 |
| Defesa | Protetor de pescoço de metal | ID a confirmar (Metal Neck Guard) | 120 |
| Roupas | Jaqueta de bombeiro | `Base.Jacket_Fireman` (confirmar) | 160 |
| Roupas | Calça de bombeiro | `Base.Trousers_Fireman` (confirmar) | 130 |
| Roupas | Jaqueta militar | `Base.Jacket_ArmyCamoGreen` (confirmar) | 110 |
| Roupas | Calça militar | `Base.Trousers_ArmyService` (confirmar) | 100 |
| Remédios | Pinça | `Base.Tweezers` (confirmar) | 20 |
| Remédios | Lenços com álcool | `Base.AlcoholWipes` (confirmar) | 8 |
| Remédios | Kit de primeiros socorros do mod (4 bandagens esterilizadas, 1 desinfetante, 1 tala, 1 analgésico) | item próprio do mod | 90 |
| Barricadas | Chapa metálica | `Base.SheetMetal` | 45 |
| Barricadas | Maçarico | `Base.BlowTorch` | 150 |
| Barricadas | Varetas de solda | `Base.WeldingRods` | 30 |
| Barricadas | Máscara de solda | `Base.WeldingMask` (confirmar) | 70 |
| Barricadas | Arame farpado | `Base.BarbedWire` (confirmar) | 35 |

### Igrejas 4 · West Point e 5 · Louisville

Catálogo igual ao da igreja 3. Vencer a 4 dá 10% de desconto em toda a loja, e vencer a 5 dá 20% (proposta).

## 4. Serviços da igreja (drenos de moedas)

| Serviço | Preço | Observação |
| --- | --- | --- |
| Teleporte entre igrejas conquistadas | 10 por salto | Regras no GDD, seção 2.2 |
| Conserto de arma no altar | 20% do preço de loja da arma | Restaura a condição. Armas que não estão na loja pagam pela tabela de categoria (definir na spec) |
| Reroll extra de buff | 15 × número da igreja | Além do reroll grátis de cada oferta |

## 5. Totais

| Etapa | Itens novos | Catálogo acumulado |
| --- | --- | --- |
| Loja Básica | 9 | 9 |
| Igreja 1 | 17 | 26 |
| Igreja 2 | 22 | 48 |
| Igreja 3 | 27 | 75 |
| Igrejas 4 e 5 | 0 | 75 |

## 6. Para conferir no playtest

1. Com cerca de 235 moedas depois da igreja 1, o jogador consegue M9 + 3 caixas + remédios, ou a JS-2000 + 2 caixas. Ele precisa vencer a igreja 2 com isso.
2. Se a renda fora do cerco for muito maior que 40 a 120 moedas por hora (ex.: farmar horda com arma), subir todos os preços por um multiplicador nas opções de sandbox, e não item a item.
3. Limite de estoque, se o grupo acumular armas demais: por exemplo, no máximo 2 armas de fogo por jogador a cada cerco.
