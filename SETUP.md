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

## Etapa 2 — Template de repositório (2026-10-21)

Decisões: licença **MIT**; template `FreddiSantos/python-project-template`.

| Arquivo | O que faz |
|---|---|
| `README.md` | esqueleto: problema, solução, como rodar, dados, reprodutibilidade, stack, resultados, roadmap, licença |
| `LICENSE` | MIT (texto oficial da API do GitHub), © 2026 Pedro Freddi |
| `CODE_OF_CONDUCT.md` | Contributor Covenant **3.0** oficial; denúncias pelo LinkedIn (sem e-mail pessoal) |
| `CONTRIBUTING.md`, `SECURITY.md` | como contribuir; vulnerabilidades via *Report a vulnerability* (privado) |
| `.github/ISSUE_TEMPLATE/*`, `pull_request_template.md` | formulários de bug/feature e checklist de PR |
| `.github/CODEOWNERS` | você revisa tudo |
| `.editorconfig`, `.gitattributes` | UTF-8, LF, 4 espaços em Python |
| `.gitignore` | Python + dados (`data/*`, `*.csv`, `*.parquet`…) + modelos (`*.pt`, `*.safetensors`…) + secrets (`.env`, `*.key`…) |
| `pyproject.toml`, `uv.lock`, `.python-version` | projeto com **uv**, Python 3.13, dependências travadas (reprodutibilidade) |
| `.github/workflows/ci.yml` | a cada push/PR: `ruff check`, `ruff format --check`, `pytest`, `uv build` |

**Por que uv + ruff:** o uv substitui pip, venv e pyenv, instala o Python certo sozinho e gera um lockfile (mesmas versões em qualquer máquina). O ruff faz lint e formatação numa ferramenta só, no lugar de flake8, isort e black. Ambos são da Astral e recebem releases semanais.

**Verificação:** rodei localmente os mesmos passos do CI: lint ✅, formatação ✅, 3 testes ✅ e build ✅.

**Ajustes de padrão de mercado** (você delegou a escolha):

| Ajuste | Por quê |
|---|---|
| Actions fixadas por **SHA** com a versão em comentário | uma tag pode ser movida por quem controla a action; o SHA não. É a recomendação do GitHub e da OpenSSF, e o Dependabot atualiza os dois |
| CI dividido em `lint`, `test` e `build`; `build` só roda se os outros passarem | erros aparecem separados e mais rápido |
| Testes em **Python 3.12 e 3.13** (matriz) | garante que funciona nas versões suportadas |
| Cobertura com **pytest-cov**, mínimo de 80% | métrica de qualidade que recrutadores reconhecem |
| `timeout-minutes` em cada job | um job travado não consome minutos do Actions |
| `CITATION.cff` | GitHub mostra "Cite this repository"; padrão em projetos acadêmicos e de pesquisa (LIA) |
| `.env.example` com `SEED=42` | mostra como configurar chaves sem expor secrets, e fixa a semente |
| `.vscode/extensions.json` | o VS Code sugere as extensões certas (Python, Ruff) |
| README com estrutura de pastas, hardware e citação | reprodutibilidade e leitura rápida |

Verificado de novo: lint ✅, testes em 3.12 e 3.13 ✅ (cobertura 100%), build ✅, `CITATION.cff` válido pelo `cffconvert` ✅.

### Publicação (2026-10-21, aprovada por você)

- [FreddiSantos/python-project-template](https://github.com/FreddiSantos/python-project-template): público, **marcado como template**, licença MIT detectada.
- Topics: `python`, `template`, `data-science`, `machine-learning`, `uv`, `ruff`, `github-actions`.
- **Private vulnerability reporting** ativado (`PUT /repos/.../private-vulnerability-reporting`). É isso que faz funcionar o botão citado no `SECURITY.md`. Para desativar: Settings → Security → *Private vulnerability reporting*.
- Community health do GitHub: **100%**.
- CI no GitHub: Lint ✅, Test 3.12 ✅, Test 3.13 ✅, Build ✅.

**Como usar:** na página do template, *Use this template → Create a new repository*, ou:
`gh repo create FreddiSantos/<nome> --template FreddiSantos/python-project-template --public --clone`
Depois siga o checklist no comentário do topo do README.

> O relato privado de vulnerabilidades **não é copiado** para os repositórios criados a partir do template; ele precisa ser ativado em cada um (isso entra na automação da Etapa 3).

**Observações:**
- `*.csv` é ignorado em todo o repositório. Se um projeto precisar versionar um CSV pequeno de exemplo, use `git add -f arquivo.csv`.
- Os templates de issue aplicam as labels `type: bug`, `type: feature` e `status: triage`, que serão criadas na Etapa 4. Até lá, o GitHub simplesmente ignora as labels inexistentes.
- `setup-uv` não publica mais tag de versão principal (`v10`); por isso está fixado em `v10.3.0`. O Dependabot (Etapa 3) vai atualizar.

### Instalado nesta etapa

| Item | Como | Por quê | Como reverter |
|---|---|---|---|
| uv 0.13.4 | `winget install --id astral-sh.uv` (portátil, sem admin) | gerenciar Python e dependências; necessário para o pre-commit na Etapa 3 | `winget uninstall --id astral-sh.uv` |
| Python 3.13.16 (gerenciado pelo uv) | baixado automaticamente pelo `uv` | rodar os testes localmente | `uv python uninstall 3.13` |

**Erro encontrado:** dentro do app do Claude (pacote MSIX), gravações em `AppData\Roaming` são redirecionadas para uma pasta virtual, e o uv não conseguiu criar o atalho do Python 3.13 lá. Nos comandos do Claude, o Python fica em `C:\Users\pedro\.local\share\uv\python` (`UV_PYTHON_INSTALL_DIR`). No seu terminal normal o uv funciona no local padrão, sem ajuste.

## Etapa 3 — Qualidade e segurança (2026-10-21)

### Escolhas

| Ferramenta | Escolha | Por quê |
|---|---|---|
| Atualização de dependências | **Dependabot** (não Renovate) | Nativo do GitHub: sem instalar app nem dar permissões a terceiros. Suporta `uv`, `github-actions` e `pre-commit` (conferido na documentação em 2026-10-21). É o que o `dependabot/fetch-metadata` usa para o auto-merge da Etapa 5. O Renovate é mais configurável, mas exige instalar um GitHub App. |
| Análise estática | **CodeQL** (workflow avançado, `security-extended`) | Gratuito em repositório público. Analisa Python **e** os próprios workflows (`actions`), que são um vetor de ataque comum. |
| Secrets | **Secret scanning + push protection** (GitHub) + **gitleaks** (local) | Já vinham ativos em repositórios públicos. O gitleaks barra o secret **antes** do commit, no seu computador. |
| Hooks locais | **pre-commit** 4.7.0 | Padrão de mercado. Os mesmos hooks rodam no CI (job `lint`), então a regra é uma só. |
| Mensagens de commit | **conventional-pre-commit** (local) + **commitlint** (CI) | O commitlint precisa de Node, que você não tem. O hook local em Python faz a mesma checagem no `commit-msg`, e o commitlint roda no GitHub, sobre os commits e o título do PR. |
| Releases | **release-please** v5 | Lê os commits `feat:` e `fix:`, abre um PR de release com CHANGELOG e versão, e cria a tag e a release no merge. Não publica nada sem você aprovar o PR. |

### Configurações nos repositórios (`scripts/Set-RepoDefaults.ps1`)

Aplicado em `FreddiSantos`, `github-setup` e `python-project-template`, verificado pela API:

| Configuração | Estado |
|---|---|
| Dependabot alerts e security updates | ativados |
| Secret scanning + push protection | ativados (já vinham por padrão) |
| Private vulnerability reporting | ativado |
| Token padrão do Actions | **somente leitura**; cada workflow declara o que precisa |
| Actions pode abrir PRs | só no template (release-please precisa) |
| Merge | só **Squash and merge**, com o título do PR como mensagem; branch apagada após o merge |

**Para um repositório novo:** `powershell -ExecutionPolicy Bypass -File scripts\Set-RepoDefaults.ps1 -Repo FreddiSantos/<nome> -AllowActionsPullRequests`

### Arquivos por repositório

| Arquivo | Template | Perfil | github-setup |
|---|:-:|:-:|:-:|
| `.github/dependabot.yml` (uv / actions / pre-commit, semanal, agrupado) | ✅ uv + actions + pre-commit | ✅ actions + pre-commit | ✅ pre-commit + actions |
| `.github/workflows/codeql.yml` (actions + python) | ✅ | ✅ | — (ainda sem código analisável) |
| `.pre-commit-config.yaml` | ✅ completo | ✅ higiene + ruff + gitleaks + commit-msg | ✅ higiene + gitleaks + commit-msg |
| `.github/workflows/commitlint.yml` + `commitlint.config.mjs` | ✅ | — | — |
| `.github/workflows/release-please.yml` + config + manifest | ✅ | — | — |
| CI `lint` rodando o pre-commit | ✅ | — | — |

No template, os hooks são: higiene de arquivos, bloqueio de arquivos > 1 MB, `detect-private-key`, ruff (lint + formatação), `uv-lock`, `nbstripout` (limpa saídas de notebooks), gitleaks e Conventional Commits.

### Testes feitos

- pre-commit nos 3 repositórios: todos os hooks passam ✅. Na primeira rodada ele **corrigiu** linhas em branco sobrando no fim de `CODE_OF_CONDUCT.md` e `LICENSE`, e reformatou `sync_pinned.py`.
- Commit com mensagem `"mudei umas coisas"`: **bloqueado** ✅.
- Arquivo com um token falso no formato `ghp_...`: **bloqueado** pelo gitleaks ✅ (regra `github-pat`). Com a chave de exemplo da AWS (contém "EXAMPLE") ele não bloqueia, de propósito.
- `uv sync --locked` com a versão alterada no `pyproject.toml`: **quebra**. Por isso o workflow do release-please roda `uv lock` no próprio PR de release.

### Limitações conhecidas

- PRs e commits criados pelo `GITHUB_TOKEN` (release-please, sync dos fixados) **não disparam** outros workflows: o PR de release não roda CI. É uma regra do GitHub contra loops. Para mudar seria preciso um PAT ou um GitHub App; por ora não vale a pena.
- `lowlighter/metrics` continua em `@latest` (canal estável recomendado pelo projeto); as demais actions estão fixadas por SHA.
- O ruff do pre-commit e o do `uv.lock` são versões declaradas em dois lugares. O Dependabot atualiza os dois toda semana.

### Instalar os hooks no seu computador

No seu terminal (uma vez):
```
uv tool install pre-commit
```
Depois, em cada repositório clonado: `pre-commit install`. A partir daí, todo `git commit` passa pelos hooks.

> Os clones atuais já têm os hooks instalados, mas apontando para um Python temporário do Claude. Se aparecer *"pre-commit not found"* no seu terminal, rode os dois comandos acima.

## Pendências que dependem de você

- [ ] Criar o PAT `METRICS_TOKEN` (instruções no relatório da Etapa 1) e salvar como secret do repositório de perfil
- [x] Informar a URL do LinkedIn (adicionada em 2026-10-21)
- [x] Revisar a seção **Stack** do README (definida com você em 2026-10-21)
- [ ] Preencher nome, bio, foto e links em Settings → Profile
- [ ] Ativar "Keep my email addresses private" e "Block command line pushes that expose my email" em Settings → Emails
- [ ] Ativar a autenticação em dois fatores (2FA), se ainda não estiver ativa
- [ ] Fixar repositórios pela interface (Customize your pins) conforme forem surgindo
- [ ] Instalar o pre-commit no seu terminal: `uv tool install pre-commit` (ver Etapa 3)
