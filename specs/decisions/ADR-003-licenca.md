# ADR-003: licença e dependências externas

- **Status:** aceita
- **Data:** 26/10/2026
- **Origem:** [viabilidade](https://claude.ai/artifact/WojQe1M1D7Di5SrskpNkZT), seção "Mods de terceiros e licenças"; licença confirmada pelo Rodrigo em 26/10/2026

## Contexto

O mod é gratuito e de código aberto. A [política de modding da The Indie Stone](https://projectzomboid.com/blog/modding-policy/) exige permissão para reaproveitar trabalho de outros e crédito na descrição, e proíbe vender acesso ou dar bônus a doadores. Nenhum dos mods de terceiros úteis ao projeto pode ser copiado para dentro do nosso.

## Decisão

- **Código: MIT** (arquivo `LICENSE`). Vale para Lua, scripts de item, traduções, ferramentas, testes e documentação.
- **Arte: [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/deed.pt-br).** Vale para texturas, ícones, poster, preview e qualquer imagem, som ou modelo feito para o mod.
- Arte de terceiros só entra se for CC0 ou CC BY, com crédito na página do Workshop.
- Nenhum código de outro mod é copiado. Mods de terceiros entram só como dependência opcional, instalada pelo próprio servidor:

| Mod | Licença | Como usamos |
|---|---|---|
| [Bandits NPC](https://steamcommunity.com/sharedfiles/filedetails/?id=3268487204) (ID `Bandits2`) | Direitos reservados; sem reupload | Integração opcional: detectada em tempo de execução e isolada num adaptador (SPEC-079). O mod funciona sem ele. |
| [Zomboid Forge](https://github.com/SirDoggyJvla/Zomboid-Forge) | GPL-3.0 | Só referência de como fazer. Copiar código dele obrigaria o mod a virar GPL-3.0, o que exige uma ADR nova. |
| [Horde Night](https://steamcommunity.com/sharedfiles/filedetails/2714850307) | Não informada | Só inspiração. |

- Ferramentas de desenvolvimento (Umbrella, busted, luacheck, StyLua) não vão no pacote do Workshop.

## Consequências

- Qualquer um pode reaproveitar o código e a arte, desde que dê crédito.
- A integração com Bandits NPC pode quebrar a cada atualização dele, porque não há API documentada.
- Trocar de licença exige uma ADR nova que substitua esta.
