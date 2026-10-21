# Relatório final — sistema GitHub de Pedro Freddi

Data: 21/10/2026 · Conta: [FreddiSantos](https://github.com/FreddiSantos) · Registro detalhado: [SETUP.md](SETUP.md)

## 1. Antes e depois

| Item | Antes (Etapa 0) | Depois |
|---|---|---|
| Repositórios | 0 | 4 públicos: perfil, `github-setup`, `python-project-template` (template), `ai-learning-journey` |
| README de perfil | não existia | apresentação EN + PT, LinkedIn, projetos em destaque e stack; seções automáticas |
| Ferramentas locais | só git | git configurado com e-mail **noreply**, GitHub CLI, uv (Python 3.13 gerenciado), pre-commit |
| Licença | — | MIT em todos os repositórios de código |
| Saúde da comunidade (GitHub) | — | **100%** em `github-setup`, no template e na jornada |
| CI | — | lint + testes (Python 3.12 e 3.13) + build; cobertura mínima de 80% |
| Segurança | — | CodeQL, secret scanning + push protection, gitleaks local, Dependabot (alertas, correções e versões), relato privado de vulnerabilidades, actions fixadas por SHA, token do Actions só leitura |
| Padrão de commits | — | Conventional Commits obrigatório (hook local + commitlint no CI); 100% dos commits no padrão |
| Releases | — | release-please: **v0.2.0 do template publicada** com CHANGELOG automático |
| Organização | — | 27 labels padronizadas, topics em todos os repositórios, board público com automações, Discussions na jornada |
| Rotina | manual | resumo semanal, lembrete de PRs, stale e auto-merge do Dependabot, testados no GitHub |
| Proteção da main | — | ruleset em todos: sem apagar e sem force push; checks obrigatórios no template e no `github-setup` |
| Reprodutibilidade | — | `uv.lock`, Python fixado em `.python-version`, `SEED` no `.env.example`, scripts idempotentes |

## 2. Ferramentas instaladas e por quê

| Ferramenta | Por quê |
|---|---|
| **GitHub CLI** (`gh`) | automatiza tudo pela linha de comando e pela API (repositórios, labels, rulesets, board) |
| **uv** | instala o Python certo, cria ambientes e trava versões em `uv.lock`; substitui pip, venv e pyenv |
| **ruff** | lint e formatação numa ferramenta só, muito rápida |
| **pytest + pytest-cov** | testes e cobertura, padrão do mercado Python |
| **pre-commit** | roda as checagens antes de cada commit; os mesmos hooks rodam no CI |
| **gitleaks** | barra tokens e chaves **antes** de virarem commit (testado com um token falso) |
| **nbstripout** | limpa saídas de notebooks (evita vazar dados e diffs enormes) |
| **conventional-pre-commit / commitlint** | mensagens de commit padronizadas, que alimentam o CHANGELOG (o commitlint roda só no CI porque não há Node local) |
| **Dependabot** | nativo do GitHub, suporta `uv`, actions e pre-commit; preferido ao Renovate por não exigir app de terceiros |
| **CodeQL** | análise de segurança do Python **e** dos próprios workflows |
| **release-please** | versão, CHANGELOG, tag e release a partir dos commits, sempre via PR que você aprova |
| **lowlighter/metrics** | estatísticas do perfil geradas no seu próprio repositório, sem servidor de terceiros |
| **actions/stale** | avisa e fecha issues e PRs abandonados |
| **GitHub Projects** | board público: Backlog → Em andamento → Revisão → Concluído |

## 3. O que ainda depende de você

Em ordem de impacto:

1. **Ativar as métricas do perfil:** crie um token clássico **sem escopos** (github.com/settings/tokens) e rode
   `gh secret set METRICS_TOKEN -R FreddiSantos/FreddiSantos`. A imagem aparece sozinha no README no dia seguinte (ou rode `gh workflow run metrics.yml -R FreddiSantos/FreddiSantos`).
2. **Perfil do GitHub** (Settings → Profile): nome "Pedro Freddi", foto, bio curta, localização genérica (ex.: São Carlos, SP) e link do LinkedIn.
3. **Privacidade de e-mail** (Settings → Emails): ativar *Keep my email addresses private* e *Block command line pushes that expose my email*.
4. **2FA** (Settings → Password and authentication), se ainda não estiver ativo.
5. **Instalar o pre-commit no seu terminal:** `uv tool install pre-commit`.
6. **Fixar repositórios** (perfil → *Customize your pins*). Até lá, o README mostra os repositórios mais recentes.
7. **Board → `···` → Workflows:** ligar *Auto-add to project* (`is:issue,pr is:open`) e pôr *Pull request linked to issue* em **Revisão**. A API não permite configurar isso.
8. **PRs da jornada:** aprovar e fazer merge do PR #1 (Dependabot) e depois do PR #2 (release 0.2.0). O merge direto por mim foi bloqueado pela proteção do modo automático do Claude Code. No PR de release, clique em *Approve workflows to run* antes.
9. **Datas da LIA e do PET:** editar `journey.toml` (campo `date = "AAAA-MM"`).

## 4. Sugestões de conteúdo (não feitas; exigem seu julgamento)

- **Primeiro projeto real de IA + Engenharia Civil** é o que mais falta para a credibilidade. Ideias com dados públicos: previsão da resistência à compressão do concreto (dataset UCI *Concrete Compressive Strength*), detecção de fissuras em imagens (datasets públicos de *crack detection*), ou um assistente com LLM para consultar normas técnicas (respeitando direitos autorais das normas).
- Em cada projeto: **screenshot ou GIF** no topo do README, **métrica de resultado** comparada com um baseline e **diagrama** da solução (Mermaid renderiza direto no GitHub, como no README do `github-setup`).
- **Social preview** (Settings → Social preview) com uma imagem 1280×640 por repositório: melhora a aparência quando o link é compartilhado no LinkedIn.
- Trazer trabalhos da **LIA** e do **PET** para o GitHub, com autorização dos grupos e sem dados pessoais.
- Postar no LinkedIn quando sair uma release ou um projeto novo, com link para o repositório.

## 5. Próximos passos recomendados

1. Criar o primeiro projeto com `gh repo create FreddiSantos/<nome> --template FreddiSantos/python-project-template --public --clone` e seguir o checklist do README.
2. Registrar cursos e leituras no `journey.toml` à medida que acontecerem.
3. Usar o board: cada ideia vira issue, com labels `type:` e `priority:`.
4. Ler o resumo semanal de segunda-feira (issue no `github-setup`).
5. Quando houver 3 ou mais projetos, retomar a ideia do **portfólio** no GitHub Pages.

## 6. Decisões e limites importantes

- **Regras da main:** no perfil e na jornada, os workflows precisam commitar direto na main. O GitHub **não aceita** o GitHub Actions como exceção de ruleset em contas pessoais. Por isso, nesses dois repositórios a regra protege só contra apagar a main e contra force push. Para não perder segurança, o auto-merge do Dependabot **espera explicitamente** todas as execuções de CI do PR terminarem com sucesso antes do merge.
- **PRs abertos por bots** (release-please) precisam que você aprove a execução dos checks: proteção do GitHub contra loops.
- **Merges feitos por bots** não disparam workflows na main; o próximo push seu dispara.
