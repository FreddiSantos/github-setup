# SETUP — sistema GitHub de Pedro Freddi

Registro de tudo o que foi configurado: o quê, por quê, como reverter e o que depende de você.
Conta: [`FreddiSantos`](https://github.com/FreddiSantos) · Plano: Free

## Decisões

| Decisão | Escolha | Data |
|---|---|---|
| Nome de usuário | manter `FreddiSantos` | 2026-10-21 |
| Idioma dos READMEs | inglês, com resumo em português | 2026-10-21 |
| Visibilidade padrão | público (cada repositório novo precisa da sua aprovação) | 2026-10-21 |
| Portfólio | só o README do perfil por enquanto; site quando houver 3+ projetos | 2026-10-21 |
| Estatísticas do perfil | `lowlighter/metrics` | 2026-10-21 |

## Etapa 0 — Diagnóstico (2026-10-21)

**Estado inicial:** conta sem repositórios, sem perfil preenchido, sem organizações; nenhum projeto local.
Ambiente: Windows 11, git 2.55, winget. Sem gh, Python, Node e Docker.

### Instalado / configurado

| Item | Como | Por quê | Como reverter |
|---|---|---|---|
| GitHub CLI 2.102.1 | `winget install --id GitHub.cli` (em `C:\Program Files\GitHub CLI`) | criar repositórios, labels, secrets e consultar a API | `winget uninstall --id GitHub.cli` |
| Login do gh | `gh auth login --web` (token no Windows Credential Manager) | autenticação do gh e do `git push` | `gh auth logout` |
| Identidade do git | `git config --global user.name/user.email` | commits assinados com o e-mail **noreply**, sem expor o e-mail pessoal | `git config --global --unset user.email` |
| `init.defaultBranch=main`, `pull.rebase=false` | `git config --global` | padrão atual do GitHub; evita aviso no `git pull` | `git config --global --unset <chave>` |

Tudo isso é reaplicável com [`bootstrap/bootstrap.ps1`](bootstrap/bootstrap.ps1).

### Erros encontrados e como foram resolvidos

- **winget travou rodando em segundo plano** (instalação MSI esperando elevação). O processo foi interrompido e usamos temporariamente o zip portátil oficial (SHA-256 conferido com o `checksums.txt` da release). Depois o MSI concluiu sozinho; a cópia portátil e a entrada dela no PATH foram removidas para não haver duas versões.
- **`gh` não reconhecido no terminal**: abas abertas antes da instalação não enxergam o PATH novo. A solução é abrir um terminal novo.
- **Bootstrap tentava reinstalar o gh**: o PATH era recarregado só depois da verificação. Corrigido: recarrega antes e depois. O `.ps1` é salvo em UTF-8 **com BOM**, porque o Windows PowerShell 5.1 lê UTF-8 sem BOM como ANSI e estraga a acentuação.

> ⚠️ Esta pasta está dentro do **OneDrive**. Sincronizar `.git` pelo OneDrive pode gerar conflitos se você editar em dois computadores. Se isso acontecer, mova os repositórios para fora do OneDrive (ex.: `C:\dev`), já que o GitHub é o backup.

## Etapa 1 — Perfil e vitrine

Repositório de perfil: `FreddiSantos/FreddiSantos` (o README dele aparece na página do perfil).

| Arquivo | O que faz |
|---|---|
| `README.md` | apresentação (EN + resumo PT), projetos em destaque, em andamento, stack, métricas |
| `.github/workflows/metrics.yml` | gera `github-metrics.svg` diariamente (03:00 BRT) com `lowlighter/metrics` |
| `.github/workflows/sync-pinned.yml` | toda segunda (04:00 BRT) reescreve "Featured projects" com os repositórios fixados |
| `scripts/sync_pinned.py` | script usado pelo workflow acima; só biblioteca padrão; idempotente |

**Por que `lowlighter/metrics`:** é o gerador de métricas mais completo (40+ plugins) e roda como Action, então o SVG fica versionado no seu repositório, sem depender de um servidor de terceiros. O `github-readme-stats` é mais popular, mas a instância pública vive com limite de requisições e recomenda hospedar a própria. Ponto de atenção: a última release do metrics é de 2023, embora o repositório siga recebendo commits (último em maio de 2026). Se quebrar, a alternativa é trocar pelo `github-readme-stats` auto-hospedado.

**Por que "Featured projects" é gerado por script:** a API do GitHub **não tem** mutation para fixar repositórios no perfil (conferido por introspecção do schema GraphQL em 2026-10-21; só existem `pinIssue`, `pinIssueComment` e `pinEnvironment`). Então você fixa pela interface e o workflow espelha isso no README.

**Para desativar:** Actions → escolha o workflow → `···` → *Disable workflow*.

### Publicação (2026-10-21, aprovada por você)

| Repositório | Visibilidade | Como reverter |
|---|---|---|
| [FreddiSantos/FreddiSantos](https://github.com/FreddiSantos/FreddiSantos) | pública | Settings → Danger Zone → visibilidade ou exclusão |
| [FreddiSantos/github-setup](https://github.com/FreddiSantos/github-setup) | pública | idem |

**Verificação:**
- `Sync pinned projects` rodado manualmente: ✅ sucesso ("README já estava em dia"; nenhum commit, como esperado sem fixados).
- `Metrics`: ❌ falhou no primeiro push com "You must provide a valid GitHub personal token". **Esperado** até o secret `METRICS_TOKEN` ser criado. Depois disso, rode de novo: `gh workflow run metrics.yml -R FreddiSantos/FreddiSantos`.

## Pendências que dependem de você

- [ ] Criar o PAT `METRICS_TOKEN` (instruções no relatório da Etapa 1) e salvar como secret do repositório de perfil
- [x] Informar a URL do LinkedIn (adicionada em 2026-10-21)
- [ ] Revisar a seção **Stack** do README (preenchida com uma base mínima)
- [ ] Preencher nome, bio, foto e links em Settings → Profile
- [ ] Ativar "Keep my email addresses private" e "Block command line pushes that expose my email" em Settings → Emails
- [ ] Ativar a autenticação em dois fatores (2FA), se ainda não estiver ativa
- [ ] Fixar repositórios pela interface (Customize your pins) conforme forem surgindo
