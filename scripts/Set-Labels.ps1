# Cria ou atualiza as labels padronizadas (labels\labels.json) em um ou mais repositórios.
# Apaga as labels padrão do GitHub listadas em "replace_defaults", mas SÓ se nenhuma
# issue ou PR as estiver usando. Idempotente.
#
# Uso:
#   powershell -ExecutionPolicy Bypass -File scripts\Set-Labels.ps1 -Repo "FreddiSantos/a,FreddiSantos/b"

param(
    # Texto com os repositórios separados por vírgula (com -File, o PowerShell não recebe arrays).
    [Parameter(Mandatory = $true)][string]$Repo
)

$ErrorActionPreference = 'Stop'
$repos = @($Repo -split ',' | ForEach-Object { $_.Trim() } | Where-Object { $_ })
$config = Get-Content -Raw -Encoding UTF8 (Join-Path $PSScriptRoot '..\labels\labels.json') | ConvertFrom-Json

foreach ($r in $repos) {
    Write-Host "== $r"

    foreach ($l in $config.labels) {
        # --force atualiza cor e descrição se a label já existir
        gh label create $l.name --repo $r --color $l.color --description $l.description --force | Out-Null
        if ($LASTEXITCODE -ne 0) { throw "Falha ao criar '$($l.name)' em $r" }
    }
    Write-Host "[ok] $($config.labels.Count) labels criadas/atualizadas"

    $existing = gh label list --repo $r --limit 200 --json name --jq '.[].name'
    foreach ($name in $config.replace_defaults) {
        if ($existing -notcontains $name) { continue }
        $issues = gh issue list --repo $r --label "$name" --state all --limit 1 --json number --jq 'length'
        $prs = gh pr list --repo $r --label "$name" --state all --limit 1 --json number --jq 'length'
        if (([int]$issues + [int]$prs) -gt 0) {
            Write-Host "[!!] '$name' está em uso; mantida"
            continue
        }
        gh label delete $name --repo $r --yes | Out-Null
        Write-Host "[del] $name"
    }
}
