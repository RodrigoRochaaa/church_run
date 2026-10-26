# JOURNAL.md: onde paramos

> Este arquivo é **sobrescrito** ao fim de cada sessão (regra no `CLAUDE.md` §11). Ele mostra só a última sessão.
> O histórico completo fica no Git: `git log -p -- JOURNAL.md`. Por isso, ao fim da sessão, o journal novo é commitado.

**Data:** 26/10/2026
**Sessão:** Repositório, ambiente e início da Fase 0
**Fase atual:** Fase 0 (Fundação), em andamento. Repositório, ferramentas, CI e esqueleto do mod prontos; SPEC-001 e SPEC-002 em rascunho, aguardando aprovação.

## Próximo passo

Revisar `specs/001-protocolo-comandos.md` e `specs/002-persistencia.md` e aprovar ou pedir mudanças, respondendo às "Questões em aberto" de cada uma (suporte a single player, limites ajustáveis pelo admin, backup antes de migrar). Com a SPEC-001 aprovada, o primeiro trabalho de código é: plano de tarefas → `.busted` com o `package.path` apontando para `Contents/mods/church_run/42/media/lua/{shared,server,client}` → testes do validador de esquema (SPEC-001 CA3) em `tests/` → implementação de `shared/ChurchRun/protocol/` (R2, R3, R5).

## O que foi feito

- Repositório Git criado na pasta do projeto e publicado em https://github.com/RodrigoRochaaa/church_run (público), com o e-mail noreply do GitHub configurado só neste repositório. O `.git` vazio da raiz `D:\` foi apagado depois de `git -C D:\ log` confirmar que não havia commits.
- `CLAUDE .md` renomeado para `CLAUDE.md`. Criada a §11 (fim de sessão e modelo do journal), registrada a exceção da UI no §3.4 e alinhado o escopo à conquista de igrejas.
- `QuestMod` trocado por `church_run` (ID) e `ChurchRun` (namespace) em todos os documentos ([ADR-004](specs/decisions/ADR-004-id-e-namespace.md)). Busca no Workshop sem colisão.
- Ferramentas: `.luacheckrc`, `.stylua.toml`, `.gitattributes`, `.gitignore`, `.emmyrc.example.json`, `.vscode/extensions.json` e CI no GitHub Actions. A primeira execução passou: luacheck 1.2.0 e busted 2.3.0, com 0 arquivos Lua e sem testes ainda.
- Esqueleto do mod: `Contents/mods/church_run/42/mod.info` e `common/`. Também `LICENSE` (MIT), `README.md` e `CHANGELOG.md`.
- ADR-001 a ADR-004; `specs/README.md`, `000-template.md` e `checklist-mp.md`; rascunhos da SPEC-001 e da SPEC-002.
- Ambiente local: Umbrella 42.21.0 em `C:\dev\Umbrella`, `.emmyrc.json` local (fora do Git), extensão EmmyLua e o link `%USERPROFILE%\Zomboid\Workshop\church_run` → repositório.
- API do B42 conferida no Lua vanilla e no Umbrella do 42.21.0 (o jogo instalado é o 42.21.0) e nas classes do jogo; os detalhes estão nas tabelas "Eventos e API" das specs.

## Decisões tomadas

- ID `church_run` e namespace `ChurchRun` (ADR-004).
- MIT para o código e CC BY 4.0 para a arte (ADR-003). A confirmar: na ADR, traduções e documentação ficaram com a MIT, junto com o código.
- Repositório público, mantido em `D:\Project_zomboid_mission`.
- Testes e lint rodam no GitHub Actions até o WSL ser instalado (`DEPENDENCIES.md`, item 12).
- `.gitattributes` com LF no lugar de `core.autocrlf`; configurações descritas no `DEPENDENCIES.md` pelos arquivos reais, sem cópias.

## Pendências e bloqueios

- SPEC-001 e SPEC-002 aguardam aprovação. Sem isso, nada de código.
- `buffs.md` e `lojas.md` apareceram na raiz durante a sessão (rascunhos de design para a SPEC-050/051 e a SPEC-041). Não foram commitados nem alterados: decidir se viram base dessas specs, se ficam fora do repositório ou se vão para outra pasta.
- Instalações que ficam com o Rodrigo: WSL + Lua 5.1, busted e luacheck antes da primeira spec com código; Project Zomboid Dedicated Server (Steam → Biblioteca → Ferramentas) para o checklist de multiplayer.
- Teste manual: abrir o jogo e conferir que "Church Run" aparece na lista de mods.
- VERIFICAR no primeiro PR com código se os globs do `.luacheckrc` (`**`) casam arquivos direto em `adapters/` e `ui/`.
- Decisões D1 a D6 (`CONTEXT.md` §7), necessárias para a Fase 1.
- Nesta máquina, o Git por HTTPS falha com OpenSSL ("unable to get local issuer certificate") e funciona com `-c http.sslBackend=schannel` (dica no `DEPENDENCIES.md` §3). O push usa SSH e funciona.

## Arquivos tocados

`CLAUDE.md` (renomeado), `CONTEXT.md`, `DEPENDENCIES.md`, `DOCS-GUIDE.md`, `JOURNAL.md`, `README.md`, `CHANGELOG.md`, `LICENSE`, `.gitattributes`, `.gitignore`, `.luacheckrc`, `.stylua.toml`, `.emmyrc.example.json`, `.vscode/extensions.json`, `.github/workflows/ci.yml`, `Contents/mods/church_run/42/mod.info`, `Contents/mods/church_run/common/.gitkeep`, `specs/README.md`, `specs/000-template.md`, `specs/checklist-mp.md`, `specs/001-protocolo-comandos.md`, `specs/002-persistencia.md`, `specs/decisions/ADR-001` a `ADR-004`
