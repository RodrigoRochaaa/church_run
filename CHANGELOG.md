# CHANGELOG

Mudanças visíveis para quem administra servidor ou joga. Formato [Keep a Changelog](https://keepachangelog.com/pt-BR/1.1.0/); a numeração das versões segue o `CLAUDE.md` §8. Versão mais nova no topo.

## [Não lançado]

Versão mínima do jogo: 42.20.

### Adicionado

- O mod aparece na lista de mods do jogo como "Church Run" (ID `church_run`, linha `Mods=\church_run`).
- Ao entrar no jogo, cliente e servidor trocam um ping: o console do servidor mostra `[ChurchRun] INFO ping` e o do cliente `[ChurchRun] INFO pong`, com o tempo de ida e volta.
- Pedidos inválidos, desconhecidos ou em excesso são recusados e registrados no log do servidor (`[ChurchRun] AUDIT ...`), com no máximo 10 linhas por jogador por minuto.
- Aviso na tela, em inglês e português, quando o cliente e o servidor usam versões diferentes do protocolo.
- Os dados do mod ficam no save do servidor (Global ModData, chave `ChurchRun_World`), com versão de esquema. A cada início, o log do servidor mostra `storage.loaded` com o número de inicializações (`bootCount`).
- Dados de uma versão mais nova do mod ou corrompidos não são sobrescritos: o servidor entra em modo seguro, registra `storage.safeMode` com uma dica e só responde ao ping. Antes de cada migração, a versão anterior fica guardada em `ChurchRun_World_backup`.
