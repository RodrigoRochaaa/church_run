# DEPENDENCIES.md: o que instalar

> Tudo aqui é **gratuito**. Os passos assumem **Windows 10/11** (com notas para Linux). Pesquisado em 26/10/2026; links no fim.
> Ferramenta nova ou trocada? Atualize este arquivo no mesmo PR (ver `DOCS-GUIDE.md`).

## 1. Obrigatório

| # | Ferramenta | Para quê | Onde |
|---|---|---|---|
| 1 | **Project Zomboid, Build 42.20+** | Rodar e testar o mod | Steam. O B42 está no branch público; não precisa escolher beta |
| 2 | **Project Zomboid Dedicated Server** | Testar como num servidor real | Steam → Biblioteca → Ferramentas (grátis para quem tem o jogo). No Linux: SteamCMD, app `380870` |
| 3 | **Git** | Versionar o código e guardar o histórico do `JOURNAL.md` | https://git-scm.com/downloads |
| 4 | **Conta no GitHub** | Hospedar o repositório aberto | https://github.com |
| 5 | **Visual Studio Code** | Editor | https://code.visualstudio.com |
| 6 | **Extensão EmmyLua** (`tangzx.emmylua`) | Autocompletar e checar tipos em Lua | Marketplace do VS Code |
| 7 | **Umbrella** | Tipos da API do PZ (classes Java, eventos) para o autocompletar | https://github.com/PZ-Umbrella/Umbrella/releases/latest |
| 8 | **WSL + Ubuntu** | Rodar Lua 5.1, testes e lint no Windows | `wsl --install` no PowerShell como administrador |
| 9 | **Lua 5.1 + LuaRocks** | Mesma versão de Lua do jogo (Kahlua é Lua 5.1) | Dentro do Ubuntu, ver §3 |
| 10 | **busted** | Testes unitários (`CLAUDE.md` §7) | `luarocks`, ver §3 |
| 11 | **luacheck** | Lint: globais proibidas, variáveis não usadas, API do jogo fora de `adapters/` | `luarocks`, ver §3 |

## 2. Opcional (recomendado)

| Ferramenta | Para quê | Onde |
|---|---|---|
| Extensão **WSL** (`ms-vscode-remote.remote-wsl`) | Rodar `busted` e `luacheck` pelo terminal do VS Code | Marketplace |
| **StyLua** + extensão `JohnnyMorganz.stylua` | Formatação automática igual para todos | https://github.com/JohnnyMorganz/StyLua |
| **GitHub Desktop** | Git com interface gráfica, se a linha de comando incomodar | https://desktop.github.com |
| **GIMP** ou **Krita** | Ícones de itens (PNG) e poster do Workshop | https://www.gimp.org · https://krita.org |
| **PZ Log Analyzer** | Filtrar logs de erro grandes | https://github.com/Calvy/PZ-Log-Analyzer |
| **Blender** | Só se um dia fizermos modelos 3D (fora da v1) | https://www.blender.org |

Não precisa: Java/JDK, descompilador, TileZed/WorldEd (não vamos editar mapa) nem nenhum mod de terceiros para desenvolver.

**Não instale EmmyLua e LuaLS (`sumneko.lua`) ao mesmo tempo:** os dois servidores de linguagem brigam e duplicam avisos. O README do Umbrella recomenda EmmyLua, porque o LuaLS não entende alguns recursos dos tipos. Se preferir LuaLS, ative o Umbrella pelo comando `Lua: Open Addon Manager`.

## 3. Passo a passo da instalação

1. **Jogo e servidor.** Instale o Project Zomboid e o Dedicated Server pela Steam. Em Propriedades do jogo → Opções de inicialização, coloque `-debug` (libera o painel F11, o console de Lua e o comando `/reloadlua`).
2. **Git.** Instale com as opções padrão e configure:
   ```bash
   git config --global user.name "Seu Nome"
   git config --global user.email "seu-email-do-github"
   git config --global core.autocrlf input
   ```
3. **Repositório.** Crie o repositório vazio no GitHub (ex.: `QuestMod`, público) e clone numa pasta curta, como `C:\dev\QuestMod`.
4. **VS Code + EmmyLua.** Instale e abra a pasta do repositório.
5. **Umbrella.** Baixe a última release e descompacte em `C:\dev\Umbrella`. A configuração está no §4.
6. **WSL.** No PowerShell como administrador: `wsl --install`, reinicie e crie o usuário do Ubuntu.
7. **Lua, testes e lint** (no terminal do Ubuntu):
   ```bash
   sudo apt update
   sudo apt install -y lua5.1 liblua5.1-0-dev luarocks build-essential
   sudo luarocks --lua-version=5.1 install busted
   sudo luarocks --lua-version=5.1 install luacheck
   lua5.1 -v && busted --version && luacheck --version
   ```
   No Linux nativo os comandos são os mesmos. No macOS: `brew install lua@5.1 luarocks` (VERIFICAR fórmula) e os mesmos `luarocks install`.
8. **Ligar o repositório ao jogo** sem copiar arquivos. No Prompt de Comando (não PowerShell):
   ```bat
   mklink /J "%USERPROFILE%\Zomboid\Workshop\QuestMod" "C:\dev\QuestMod"
   ```
   O mod aparece no menu Mods do jogo. Tudo que você salvar no VS Code o jogo lê ao reiniciar (Lua também com `/reloadlua`; scripts de item só reiniciando o jogo). No Linux: `ln -s ~/dev/QuestMod ~/Zomboid/Workshop/QuestMod`.

## 4. Arquivos de configuração (na raiz do repositório)

`.emmyrc.json`: versão de Lua do jogo e tipos do Umbrella. Acrescentar a pasta `media/lua` do jogo deixa o editor achar também as funções Lua vanilla.
```json
{
  "$schema": "https://raw.githubusercontent.com/EmmyLuaLs/emmylua-analyzer-rust/refs/heads/main/crates/emmylua_code_analysis/resources/schema.json",
  "runtime": { "version": "Lua5.1" },
  "workspace": {
    "library": [
      "C:/dev/Umbrella/library",
      "C:/Program Files (x86)/Steam/steamapps/common/ProjectZomboid/media/lua"
    ]
  }
}
```
Caminhos são de cada máquina: cada pessoa ajusta o seu, e o arquivo pode ir para o `.gitignore` com um `.emmyrc.example.json` versionado.

`.luacheckrc`: Lua 5.1, único global `QuestMod`, e API do jogo permitida só em `adapters/` e nos `Main.lua` (é o lint do `CLAUDE.md` §3.4).
```lua
std = "lua51"
globals = { "QuestMod" }
max_line_length = 120
exclude_files = { "tests/fixtures/**" }

local PZ_API = { "Events", "ModData", "getPlayer", "sendClientCommand", "sendServerCommand",
  "isClient", "isServer", "getOnlinePlayers", "getGameTime", "instanceItem", "getText",
  "getScriptManager", "ISPanel", "ISButton", "ISCollapsableWindow", "getCore" }

files["Contents/**/adapters/**"] = { read_globals = PZ_API }
files["Contents/**/Main.lua"] = { read_globals = PZ_API }
files["Contents/**/ui/**"] = { read_globals = PZ_API }   -- UI usa as classes ISUI do jogo
files["tests/**"] = { std = "+busted" }
```
A lista `PZ_API` cresce conforme os adaptadores precisarem; um global que não está nela, fora dessas pastas, vira erro de lint.

## 5. Testar em multiplayer no mesmo PC

O `CLAUDE.md` §7 exige servidor + 2 clientes. Duas formas:

**A. Rápida (host + 1 cliente, sem Steam)**, do guia da PZwiki:
```bat
cd "C:\Program Files (x86)\Steam\steamapps\common\ProjectZomboid"
start ProjectZomboid64.exe -nosteam -debug
start ProjectZomboid64.exe -nosteam
```
Na primeira janela, Hospedar → configurações → Mods → adicionar QuestMod → iniciar. Na segunda, Entrar com outro nome de usuário, IP e porta padrão. Atenção: no host o Lua de cliente e de servidor rodam juntos, então esse teste **não** substitui o B.

**B. Real (servidor dedicado + 2 clientes)**: é o item 1 do checklist de MP.
1. Rode `StartServer64.bat` (pasta do Dedicated Server) uma vez para gerar `%USERPROFILE%\Zomboid\Server\servertest.ini`.
2. No `.ini`: `Mods=\QuestMod` (no B42 o ID leva `\` antes) e `WorkshopItems=` vazio, já que o mod é local. Reinicie o servidor.
3. Abra dois clientes com `-nosteam` e entre em `127.0.0.1`, porta padrão.
4. Logs: `%USERPROFILE%\Zomboid\console.txt` (cliente) e a janela/log do servidor. VERIFICAR se o servidor dedicado lê mods locais de `Zomboid\Workshop` ou só de `Zomboid\mods`; se for o segundo, crie outro link para `Contents\mods\QuestMod`.

## 6. Ordem recomendada

1 → 2 → 3 (jogo, Git, repositório) → 4 → 5 (editor) → 8 (ligar ao jogo) → testar se o mod aparece → 6 → 7 (testes e lint, necessários a partir da primeira spec com código).

## Fontes

- [Umbrella (tipos da API do PZ)](https://github.com/PZ-Umbrella/Umbrella) e [PZEventStubs, arquivado em favor do Umbrella](https://github.com/demiurgeQuantified/PZEventStubs)
- [EmmyLua: configuração `.emmyrc.json`](https://mintlify.wiki/EmmyLuaLs/emmylua-analyzer-rust/config/emmyrc)
- [PZwiki: Testing mods in multiplayer](https://pzwiki.net/wiki/Testing_mods_in_multiplayer)
- [pz-modding-guide: testing](https://github.com/gotmayonase/pz-modding-guide/blob/main/testing.md) e [resources](https://github.com/gotmayonase/pz-modding-guide/blob/main/resources.md)
- [Template de mod B42 (estrutura `Contents/mods`, pasta `Zomboid/Workshop`)](https://github.com/LabX1/ProjectZomboid-Build42-ModTemplate)
- [Awesome PZ Build 42 resources](https://github.com/JBD-Mods/awesome-project-zomboid-build42-resources)
- [Supercraft: servidor dedicado B42 (app 380870, branch público)](https://supercraft.host/wiki/project-zomboid/build_42_dedicated_server_setup/)
- [Exercism: instalar Lua e busted](https://exercism.org/docs/tracks/lua/installation)
- [luacheck: arquivo de configuração](https://luacheck.readthedocs.io/en/stable/config.html)
