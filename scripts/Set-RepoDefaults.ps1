# Aplica as configurações padrão a um repositório público: segurança gratuita e modo de merge.
# Idempotente: rodar de novo só confirma o estado.
#
# Uso:
#   powershell -ExecutionPolicy Bypass -File scripts\Set-RepoDefaults.ps1 -Repo FreddiSantos/meu-repo
#   ... -Repo FreddiSantos/meu-repo -AllowActionsPullRequests   # para repositórios com release-please
#
# Reverter: Settings > General (Pull Requests), Settings > Security e Settings > Actions > General.

#   ... -RequiredChecks "Lint (pre-commit),Build"                # nomes dos jobs exigidos na main
#
# Ruleset "main protection": checks obrigatórios para PRs, sem apagar a main e sem force push.
# O papel admin (você) pode ignorar a regra, então push direto continua funcionando.

param(
    [Parameter(Mandatory = $true)][string]$Repo,
    [switch]$AllowActionsPullRequests,
    # Texto com os nomes dos checks separados por vírgula (com -File, o PowerShell não recebe arrays).
    [string]$RequiredChecks = ''
)

$ErrorActionPreference = 'Stop'

function Invoke-Gh([string[]]$GhArgs, [string]$Body) {
    if ($Body) {
        # O pipe do Windows PowerShell 5.1 para programas externos altera o texto;
        # por isso o corpo JSON vai por arquivo temporário (UTF-8 sem BOM).
        $tmp = [IO.Path]::GetTempFileName()
        try {
            [IO.File]::WriteAllText($tmp, $Body, (New-Object Text.UTF8Encoding($false)))
            gh api @GhArgs --input $tmp | Out-Null
        } finally {
            Remove-Item $tmp -ErrorAction SilentlyContinue
        }
    } else {
        gh api @GhArgs | Out-Null
    }
    if ($LASTEXITCODE -ne 0) { throw "gh api $($GhArgs -join ' ') falhou" }
}

Write-Host "== $Repo"

# Alertas do Dependabot (dependências com vulnerabilidade conhecida)
Invoke-Gh @('-X', 'PUT', "repos/$Repo/vulnerability-alerts")
Write-Host "[ok] Dependabot alerts"

# PRs automáticos do Dependabot para corrigir essas vulnerabilidades
Invoke-Gh @('-X', 'PUT', "repos/$Repo/automated-security-fixes")
Write-Host "[ok] Dependabot security updates"

# Botão "Report a vulnerability" (citado no SECURITY.md)
Invoke-Gh @('-X', 'PUT', "repos/$Repo/private-vulnerability-reporting")
Write-Host "[ok] Private vulnerability reporting"

# Secret scanning e push protection (gratuitos em repositórios públicos)
$security = '{"security_and_analysis":{"secret_scanning":{"status":"enabled"},"secret_scanning_push_protection":{"status":"enabled"}}}'
Invoke-Gh @('-X', 'PATCH', "repos/$Repo") $security
Write-Host "[ok] Secret scanning + push protection"

# Token padrão do Actions só com leitura; cada workflow pede o que precisa.
# Com -AllowActionsPullRequests, o Actions também pode abrir PRs (exigido pelo release-please).
$canPr = if ($AllowActionsPullRequests) { 'true' } else { 'false' }
Invoke-Gh @('-X', 'PUT', "repos/$Repo/actions/permissions/workflow") "{`"default_workflow_permissions`":`"read`",`"can_approve_pull_request_reviews`":$canPr}"
Write-Host "[ok] Actions: token padrão read-only, criar PRs = $canPr"

# Só "Squash and merge", usando o título do PR como mensagem: cada PR vira um commit
# Conventional Commits na main, que é o que o release-please lê para o CHANGELOG.
# Branches de PR são apagadas depois do merge.
$merge = '{"allow_squash_merge":true,"allow_merge_commit":false,"allow_rebase_merge":false,' +
         '"squash_merge_commit_title":"PR_TITLE","squash_merge_commit_message":"PR_BODY",' +
         '"delete_branch_on_merge":true,"allow_auto_merge":true}'
Invoke-Gh @('-X', 'PATCH', "repos/$Repo") $merge
Write-Host "[ok] Merge: só squash (título do PR), apagar branch após merge, auto-merge permitido"

# Ruleset da branch padrão
$checks = @($RequiredChecks -split ',' | ForEach-Object { $_.Trim() } | Where-Object { $_ })
$rules = @(@{ type = 'deletion' }, @{ type = 'non_fast_forward' })
if ($checks.Count -gt 0) {
    $rules += @{
        type       = 'required_status_checks'
        parameters = @{
            strict_required_status_checks_policy = $false
            required_status_checks               = @($checks | ForEach-Object { @{ context = $_ } })
        }
    }
}
$ruleset = @{
    name          = 'main protection'
    target        = 'branch'
    enforcement   = 'active'
    conditions    = @{ ref_name = @{ include = @('~DEFAULT_BRANCH'); exclude = @() } }
    # actor_id 5 = papel "Repository admin" (você). O GitHub NÃO aceita o GitHub Actions como
    # bypass em contas pessoais ("must be part of the ruleset source or owner organization"):
    # em repositórios onde workflows commitam na main (perfil, jornada), rode sem -RequiredChecks.
    bypass_actors = @(@{ actor_id = 5; actor_type = 'RepositoryRole'; bypass_mode = 'always' })
    rules         = $rules
} | ConvertTo-Json -Depth 10

# Filtra no PowerShell: o 5.1 parte argumentos com espaços/aspas ao chamar programas externos.
# Os parênteses em volta do ConvertFrom-Json são necessários: no 5.1 ele entrega o array
# inteiro como UM objeto, e o Where-Object não enumeraria os itens.
$existingId = ((gh api "repos/$Repo/rulesets" | ConvertFrom-Json) |
    Where-Object { $_.name -eq 'main protection' } | Select-Object -First 1).id
if ($existingId) {
    Invoke-Gh @('-X', 'PUT', "repos/$Repo/rulesets/$existingId") $ruleset
    Write-Host "[ok] Ruleset 'main protection' atualizado (checks: $($checks -join ', '))"
} else {
    Invoke-Gh @('-X', 'POST', "repos/$Repo/rulesets") $ruleset
    Write-Host "[ok] Ruleset 'main protection' criado (checks: $($checks -join ', '))"
}
