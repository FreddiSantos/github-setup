# Prepara o ambiente local para trabalhar com o GitHub.
# Idempotente: rodar várias vezes deixa o mesmo resultado.
# Uso: powershell -ExecutionPolicy Bypass -File bootstrap\bootstrap.ps1

$ErrorActionPreference = 'Stop'

function Ensure-WingetPackage([string]$Id, [string]$Command) {
    if (Get-Command $Command -ErrorAction SilentlyContinue) {
        Write-Host "[ok] $Command já instalado"
        return
    }
    Write-Host "[..] instalando $Id"
    winget install --id $Id -e --source winget --accept-package-agreements --accept-source-agreements
}

function Ensure-GitConfig([string]$Key, [string]$Value) {
    $current = git config --global --get $Key
    if ($current -eq $Value) {
        Write-Host "[ok] git $Key"
    } else {
        git config --global $Key $Value
        Write-Host "[set] git $Key = $Value"
    }
}

function Refresh-Path {
    $env:Path = [Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' + [Environment]::GetEnvironmentVariable('Path', 'User')
}

# Ferramentas (o PATH é recarregado antes e depois, porque terminais antigos não enxergam instalações novas)
Refresh-Path
Ensure-WingetPackage 'Git.Git' 'git'
Ensure-WingetPackage 'GitHub.cli' 'gh'
Refresh-Path

# Identidade do git: e-mail noreply para não expor o e-mail pessoal
Ensure-GitConfig 'user.name' 'Pedro Freddi'
Ensure-GitConfig 'user.email' '195593664+FreddiSantos@users.noreply.github.com'
Ensure-GitConfig 'init.defaultBranch' 'main'
Ensure-GitConfig 'pull.rebase' 'false'

# Autenticação (o login em si é interativo e fica com você)
gh auth status *> $null
if ($LASTEXITCODE -ne 0) {
    Write-Host "[!!] gh sem login. Rode: gh auth login --hostname github.com --git-protocol https --web"
} else {
    Write-Host "[ok] gh autenticado"
    gh auth setup-git
}
