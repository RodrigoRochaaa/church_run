# ROADMAP.md: os passos, em ordem

As **fases** e a regra de prioridade estão no [`CONTEXT.md`](CONTEXT.md) §6. Este arquivo quebra cada fase em passos pequenos, com dependências e status. Como escolher o próximo passo: [`GUIA-CLAUDE.md`](GUIA-CLAUDE.md) §1.

Status: **pendente**, **em andamento**, **aguardando teste**, **aguardando Rodrigo**, **bloqueado**, **concluído**.
Atualizado em: 26/10/2026.

- **Prova técnica:** responde uma pergunta do GDD §12 e gera um relatório em `research/`. Cada fase começa pelas provas dela.
- **Teste no jogo:** depende do Rodrigo, porque o Claude na nuvem não roda o jogo.

---

## Fase 0 · Fundação

| Passo | O que entrega | Depende de | Referência | Status |
| --- | --- | --- | --- | --- |
| P00 | Repositório no GitHub, ambiente do `DEPENDENCIES.md`, esqueleto de pastas e `mod.info` do church_run carregando sem erro | — | `DEPENDENCIES.md`, `CONTEXT.md` §5 | aguardando teste: repositório, CI, esqueleto e `mod.info` feitos em 26/10/2026; falta o Rodrigo ver o mod na lista do jogo sem erro e instalar o Dedicated Server |
| P01 | Decisões em aberto fechadas: ADR-002 (progressão global) e ADR-003 (licença e dependências) | — | GDD §14, ADR-002, ADR-003 | concluído (26/10/2026) |
| P02 | Protocolo de comandos e persistência; ida e volta cliente/servidor funcionando | P00 | SPEC-001, SPEC-002 | aguardando Rodrigo: SPEC-001 e SPEC-002 em rascunho, para aprovar |

## Fase 1 · Igreja 1 jogável (Rosewood)

Meta: dois jogadores conquistam Rosewood num servidor dedicado.

| Passo | O que entrega | Depende de | Referência | Status |
| --- | --- | --- | --- | --- |
| P03 | Prova técnica: teleportar o jogador no MP sem o anti-cheat agir | P02 | GDD §2.2, §12 | pendente |
| P04 | Prova técnica: gerar zumbis em pontos fixos a 40–60 tiles e mandá-los até a porta; medir o raio da área carregada | P02 | GDD §4.3, §12 | pendente |
| P05 | Prova técnica: painel fixo à esquerda e símbolo no mapa | P02 | GDD §9, §12 | pendente |
| P06 | Dados da igreja de Rosewood: altar, raio, 6 a 10 âncoras, ponto de nascimento (roteiro do Claude, coleta do Rodrigo no modo debug) | P00 | SPEC-010 | pendente |
| P06a | Kit do Peregrino: mochila básica com taco e 3 bandagens no personagem novo; enquanto Rosewood não for conquistada, a mochila traz a relíquia de Rosewood. As 30 moedas do kit entram com o P13 | P02 | SPEC-011 (kit no nascimento), SPEC-020 (altar com relíquia), GDD §11.1. VERIFICAR B42: item dado pelo servidor aparece no cliente sem sincronização extra | pendente |
| P07 | Cerco: estados, votação, participantes, gerador de zumbis e ondas da igreja 1 | P04, P06, P06a | SPEC-020, 021, 022 | pendente |
| P08 | Morte no cerco e sala de espera | P03, P07 | SPEC-030 | pendente |
| P09 | Nascimento pela igreja conquistada mais recente | P03, P07 | SPEC-011 | pendente |
| P10 | HUD mínimo: onda e tempo | P05, P07 | SPEC-060 (parte) | pendente |
| P11 | Teste no jogo da fatia (checklist de MP do `CLAUDE.md` §7) e ajuste dos números | P07 a P10 | `CLAUDE.md` §7 | pendente |

## Fase 2 · Economia

| Passo | O que entrega | Depende de | Referência | Status |
| --- | --- | --- | --- | --- |
| P12 | Prova técnica: o servidor sabe quem matou cada zumbi no MP | P02 | GDD §6.1, §12 | pendente |
| P13 | Moedas: 1 por zumbi (carteira virtual ou item, conforme a decisão do GDD §14) | P12, P01 | SPEC-040 | pendente |
| P14 | Lojas: Loja Básica e catálogo da igreja 1, na janela do altar | P13 | SPEC-041, SPEC-062, `design/lojas.md` | pendente |
| P15 | Serviços do altar: conserto de arma | P14 | SPEC-043 | pendente |

## Fase 3 · Buffs

| Passo | O que entrega | Depende de | Referência | Status |
| --- | --- | --- | --- | --- |
| P16 | Rodrigo escolhe os 30 buffs finais | — | `design/buffs.md` | aguardando Rodrigo |
| P17 | Sorteio de 3, reroll (grátis e pago), posse por personagem e perda na morte | P11, P16 | SPEC-050, SPEC-051 | pendente |

## Fase 4 · Interface completa

| Passo | O que entrega | Depende de | Referência | Status |
| --- | --- | --- | --- | --- |
| P18 | HUD completo: carteira, onda, tempo, restantes, buffs ativos | P10, P13, P17 | SPEC-060 | pendente |
| P19 | Ícones no mapa: igreja conquistada e próxima igreja | P05 | SPEC-061 | pendente |

## Fase 5 · Igrejas 2 a 5

| Passo | O que entrega | Depende de | Referência | Status |
| --- | --- | --- | --- | --- |
| P20 | Prova técnica: velocidade definida por zumbi | P04 | GDD §5.2, §12 | pendente |
| P21 | Base dos zumbis especiais + Corredor | P20 | SPEC-070, GDD §5.3 | pendente |
| P22 | Dados, ondas e catálogos de March Ridge, Muldraugh, West Point e Louisville | P11, P14, P21 | SPEC-010, SPEC-022, `design/lojas.md` | pendente |
| P23 | Teleporte entre igrejas conquistadas | P03, P14 | SPEC-012, GDD §2.2 | pendente |
| P24 | Campanha por cidade: relíquia escondida da igreja 2 em diante (decidido em 26/10/2026); peregrinação e preparação só se o Rodrigo aprovar (GDD §14.9) | P22, P19 | SPEC-080, GDD §7.1 | pendente (a parte de peregrinação e preparação aguarda o Rodrigo) |

## Fase 6 · Zumbis especiais

| Passo | O que entrega | Depende de | Referência | Status |
| --- | --- | --- | --- | --- |
| P25 | Prova técnica: tiro na cabeça e vida alta no MP | P21 | GDD §5.4, §12 | pendente |
| P26 | Penitente, Mochileiro, Gritador e Sineiro (sons CC0) | P21 | SPEC-071+ | pendente |
| P27 | Couraçado (regra de cabeça só se P25 confirmar) e Bomba | P25 | SPEC-07x | pendente |
| P28 | Brutamontes, Blindado de Choque e O Bispo | P25, P22 | SPEC-07x | pendente |
| P29 | Bandidos opcionais, se o Bandits NPC estiver instalado | P22 | SPEC-079 | pendente |

## Fase 7 · Publicação

| Passo | O que entrega | Depende de | Referência | Status |
| --- | --- | --- | --- | --- |
| P30 | Opções de sandbox, traduções EN e PT-BR, poster, página da Oficina, licença, checklist de MP completo | P22 a P28 | GDD §10, `CLAUDE.md` §7 | pendente |
| P31 | Publicação na Oficina (só com o Rodrigo) | P30 | — | pendente |

## Depois da 1.0

| Passo | O que entrega | Referência |
| --- | --- | --- |
| P32 | Mural de contratos diários | SPEC-081, GDD §7.2 |
| P33 | Eventos: contra-ataques e Modo Peregrino | SPEC-082, GDD §7.3 |
| P34 | Cuspidor e Espreitador (precisam de animação nova) | GDD §5.3, §5.4 |
| P35 | Segunda cadeia de cidades no oeste (Echo Creek, Ekron, Irvington, Brandenburg) | GDD §2 |
