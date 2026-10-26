# DEPENDENCIES.md: o que instalar

> Tudo aqui é **gratuito**. Os passos assumem **Windows 10/11** (com notas para Linux). Pesquisado em 26/10/2026; links no fim.
> Ferramenta nova ou trocada? Atualize este arquivo no mesmo PR (ver `DOCS-GUIDE.md`).

## 1. Obrigatório

| # | Ferramenta | Para quê | Onde |
|---|---|---|---|
| 1 | **Project Zomboid, Build 42.20+** | Rodar e testar o mod | Steam. O B42 está no branch público; não precisa escolher beta |
| 2 | **Project Zomboid Dedicated Server** | Testar como num servidor real | Grátis. O jeito mais fácil: com a Steam aberta, cole `steam://install/380870` no Executar do Windows (Win+R) e confirme. Pela Biblioteca, ele só aparece depois de marcar "Ferramentas" no menu "Jogos" do alto da lista. No Linux: SteamCMD, app `380870` |
| 3 | **Git** | Versionar o código e guardar o histórico do `JOURNAL.md` | https://git-scm.com/downloads |
| 4 | **Conta no GitHub** | Hospedar o repositório aberto | https://github.com |
| 5 | **Visual Studio Code** | Editor | https://code.visualstudio.com |
| 6 | **Extensão EmmyLua** (`tangzx.emmylua`) | Autocompletar e checar tipos em Lua | Marketplace do VS Code |
| 7 | **Umbrella** | Tipos da API do PZ (classes Java, eventos) para o autocompletar e para conferir se uma função existe no B42. Use a tag igual à versão do jogo (ex.: `42.21.0`) | https://github.com/PZ-Umbrella/Umbrella/releases/latest |
| 8 | **WSL + Ubuntu** | Rodar Lua 5.1, testes e lint no Windows. Até instalar, o CI do GitHub roda testes e lint (item 12) | `wsl --install` no PowerShell como administrador |
| 9 | **Lua 5.1 + LuaRocks** | Mesma versão de Lua do jogo (Kahlua é Lua 5.1) | Dentro do Ubuntu, ver §3 |
| 10 | **busted** | Testes unitários (`CLAUDE.md` §7) | `luarocks`, ver §3 |
| 11 | **luacheck** | Lint: globais proibidas, variáveis não usadas, API do jogo fora de `adapters/` | `luarocks`, ver §3 |
| 12 | **GitHub Actions** | Rodar `luacheck` e `busted` a cada push e PR, com a mesma receita do §3 | Já vem com o GitHub; configuração em `.github/workflows/ci.yml` |

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

1. **Jogo e servidor.** Instale o Project Zomboid e o Dedicated Server pela Steam (o servidor fica escondido em "Ferramentas"; atalho no item 2 da tabela acima). Em Propriedades do jogo → Opções de inicialização, coloque `-debug` (libera o painel F11, o console de Lua e o comando `/reloadlua`).
2. **Git.** Instale com as opções padrão e configure:
   ```bash
   git config --global user.name "Seu Nome"
   git config --global user.email "ID+usuario@users.noreply.github.com"
   ```
   - O repositório é público, e o e-mail vai em cada commit. Use o e-mail noreply do GitHub (o ID numérico sai de `gh api user --jq .id`). Para valer só neste repositório, rode o mesmo comando sem `--global`, dentro da pasta.
   - Fim de linha: não precisa configurar `core.autocrlf`. O `.gitattributes` do repositório força LF em qualquer sistema.
   - Se `git clone` por HTTPS falhar no Windows com `unable to get local issuer certificate` (antivírus ou proxy inspecionando HTTPS), use o certificado do Windows: `git config --global http.sslBackend schannel`.
3. **Repositório.** Clone numa pasta curta, como `C:\dev\church_run`: `gh repo clone RodrigoRochaaa/church_run C:\dev\church_run` (ou `git clone`). Qualquer pasta serve; o link do passo 8 aponta para ela.
4. **VS Code + EmmyLua.** Instale e abra a pasta do repositório. O VS Code oferece as extensões recomendadas em `.vscode/extensions.json`.
5. **Umbrella.** Baixe a release igual à versão do jogo e descompacte em `C:\dev\Umbrella`, ou clone a tag: `git clone --depth 1 --branch 42.21.0 https://github.com/PZ-Umbrella/Umbrella.git C:\dev\Umbrella`. A configuração está no §4.
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
   mklink /J "%USERPROFILE%\Zomboid\Workshop\church_run" "C:\dev\church_run"
   ```
   O mod aparece no menu Mods do jogo como "Church Run". Tudo que você salvar no VS Code o jogo lê ao reiniciar (Lua também com `/reloadlua`; scripts de item só reiniciando o jogo). No Linux: `ln -s ~/dev/church_run ~/Zomboid/Workshop/church_run`.

## 4. Arquivos de configuração (na raiz do repositório)

Os arquivos são a fonte da verdade; a tabela só diz para que cada um serve.

| Arquivo | O que faz |
|---|---|
| `.emmyrc.example.json` | Modelo do `.emmyrc.json` do EmmyLua: Lua 5.1, tipos do Umbrella e a pasta `media/lua` do jogo (para o editor achar também as funções Lua vanilla). Copie para `.emmyrc.json` e ajuste os caminhos da sua máquina; o `.emmyrc.json` fica fora do Git. A pasta do jogo depende da biblioteca Steam (ex.: `D:/SteamLibrary/steamapps/common/ProjectZomboid/media/lua`). |
| `.luacheckrc` | Lint: Lua 5.1, único global `ChurchRun`, API do jogo só em `adapters/` e nos `Main.lua`, e em `ui/` só as classes de interface (o lint do `CLAUDE.md` §3.4). Um global fora das listas vira erro; as listas crescem conforme os adaptadores precisarem. |
| `.stylua.toml` | Formatação do StyLua: 4 espaços, linhas de até 120 colunas, aspas duplas. |
| `.gitattributes` | LF em todos os arquivos de texto, em qualquer sistema; imagens e sons como binário. |
| `.vscode/extensions.json` | Extensões recomendadas: EmmyLua e StyLua. |
| `.github/workflows/ci.yml` | CI: instala Lua 5.1, LuaRocks, busted e luacheck no Ubuntu (mesma receita do §3, passo 7) e roda `luacheck .` e `busted`, a cada push na `main` e em todo PR. |

## 5. Testar em multiplayer no mesmo PC

O `CLAUDE.md` §7 exige servidor + 2 clientes. Duas formas:

**A. Rápida (host + 1 cliente, sem Steam)**, do guia da PZwiki:
```bat
cd "C:\Program Files (x86)\Steam\steamapps\common\ProjectZomboid"
start ProjectZomboid64.exe -nosteam -debug
start ProjectZomboid64.exe -nosteam
```
O caminho acima é o da biblioteca Steam padrão; troque pelo da sua (Steam → Configurações → Armazenamento). Na primeira janela, Hospedar → configurações → Mods → adicionar Church Run → iniciar. Na segunda, Entrar com outro nome de usuário, IP e porta padrão. Atenção: no host o Lua de cliente e de servidor rodam juntos, então esse teste **não** substitui o B.

**B. Real (servidor dedicado + 2 clientes)**: é o item 1 do checklist de MP.
1. Rode `StartServer64.bat` (pasta do Dedicated Server) uma vez para gerar `%USERPROFILE%\Zomboid\Server\servertest.ini`.
2. No `.ini`: `Mods=\church_run` (no B42 o ID leva `\` antes) e `WorkshopItems=` vazio, já que o mod é local. Reinicie o servidor.
3. Abra dois clientes com `-nosteam` e entre em `127.0.0.1`, porta padrão.
4. Logs: `%USERPROFILE%\Zomboid\console.txt` (cliente) e a janela/log do servidor. VERIFICAR se o servidor dedicado lê mods locais de `Zomboid\Workshop` ou só de `Zomboid\mods`; se for o segundo, crie outro link para `Contents\mods\church_run`.

## 6. Ordem recomendada

1 → 2 → 3 (jogo, Git, repositório) → 4 → 5 (editor) → 8 (ligar ao jogo) → testar se o mod aparece → 6 → 7 (testes e lint locais, necessários a partir da primeira spec com código). Enquanto o 6 e o 7 não estiverem prontos, o CI do GitHub (item 12) roda testes e lint em cada push e PR.

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
