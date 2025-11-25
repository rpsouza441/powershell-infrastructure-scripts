# ============================================================================
# Set-Granular-Folder-Permissions.ps1
# 
# Descrição:
#   Script para configurar permissoes granulares em estrutura de pastas.
#   Define permissoes diferentes para:
#   - Pasta pai: ReadAndExecute (sem heranca)
#   - Subpasta especifica: Modify (com heranca)
#   - Demais subpastas: Sem acesso
#
# Uso:
#   .\Set-Granular-Folder-Permissions.ps1
#   (Edite as variaveis de configuracao antes de executar)
#
# Autor: Pinheiro
# Versao: 1.0
# ============================================================================

# ===== CONFIGURACOES - EDITE AQUI =====

# Caminho base onde estao as pastas principais
$BasePath = "C:\Caminho\Para\Pasta_Base"

# Nome do grupo de dominio (sem dominio)
# Exemplo: "Grupo_Financeiro" (sera convertido para "DOMINIO\Grupo_Financeiro")
$GroupName = "Nome_Do_Grupo"

# Dominio do AD (sera usado para formar o nome completo do grupo)
$DomainName = "SEU_DOMINIO"

# Nome da subpasta que tera acesso completo (Modify)
$FullAccessFolderName = "Nome_Subpasta_Acesso_Total"

# Lista de pastas principais (onde aplicar permissao ReadAndExecute)
# Edite esta lista conforme suas necessidades
$FolderList = @(
    "Cliente_Exemplo_01",
    "Cliente_Exemplo_02",
    "Fornecedor_Exemplo_A",
    "Projeto_Exemplo_X"
)

# ===== FIM DAS CONFIGURACOES =====

# Converter grupo para formato completo (DOMINIO\Grupo)
$FullGroupName = "$DomainName\$GroupName"

# ===== FUNCOES =====

function Test-PathExists {
    param([string]$Path)
    return (Test-Path -Path $Path -PathType Container)
}

function Set-ReadOnlyFolderPermission {
    <#
    .SYNOPSIS
        Configura permissao ReadAndExecute sem heranca para subpastas
    .PARAMETER FolderPath
        Caminho da pasta a configurar
    .PARAMETER GroupName
        Nome do grupo (formato: DOMINIO\Grupo)
    #>
    param(
        [string]$FolderPath,
        [string]$GroupName
    )
    
    try {
        $ACL = Get-Acl -Path $FolderPath
        
        # Remover regras antigas do grupo
        $OldRules = $ACL.Access | Where-Object { $_.IdentityReference -eq $GroupName }
        if ($OldRules) {
            foreach ($Rule in $OldRules) {
                $ACL.RemoveAccessRule($Rule) | Out-Null
            }
        }
        
        # Adicionar ReadAndExecute - APENAS NESTA PASTA (sem heranca para subpastas)
        $NewRule = New-Object System.Security.AccessControl.FileSystemAccessRule(
            $GroupName,
            "ReadAndExecute,Synchronize",
            "None",  # None = nao herda para subpastas
            "None",
            "Allow"
        )
        $ACL.AddAccessRule($NewRule)
        Set-Acl -Path $FolderPath -AclObject $ACL
        
        return $true
    }
    catch {
        Write-Host "    ERRO: $_" -ForegroundColor Red
        return $false
    }
}

function Set-FullAccessFolderPermission {
    <#
    .SYNOPSIS
        Configura permissao Modify com heranca para subpastas
    .PARAMETER FolderPath
        Caminho da pasta a configurar
    .PARAMETER GroupName
        Nome do grupo (formato: DOMINIO\Grupo)
    #>
    param(
        [string]$FolderPath,
        [string]$GroupName
    )
    
    try {
        $ACL = Get-Acl -Path $FolderPath
        
        # Remover regras antigas do grupo
        $OldRules = $ACL.Access | Where-Object { $_.IdentityReference -eq $GroupName }
        if ($OldRules) {
            foreach ($Rule in $OldRules) {
                $ACL.RemoveAccessRule($Rule) | Out-Null
            }
        }
        
        # Adicionar Modify - COM heranca para subpastas
        $NewRule = New-Object System.Security.AccessControl.FileSystemAccessRule(
            $GroupName,
            "Modify,Synchronize",
            "ContainerInherit,ObjectInherit",  # Herda para subpastas
            "None",
            "Allow"
        )
        $ACL.AddAccessRule($NewRule)
        Set-Acl -Path $FolderPath -AclObject $ACL
        
        return $true
    }
    catch {
        Write-Host "    ERRO: $_" -ForegroundColor Red
        return $false
    }
}

# ===== VALIDACOES INICIAIS =====

Write-Host "`n" -NoNewline
Write-Host "=" * 80 -ForegroundColor Cyan
Write-Host "CONFIGURAR PERMISSOES GRANULARES - SCRIPT GENERICO" -ForegroundColor Cyan
Write-Host "=" * 80 -ForegroundColor Cyan

Write-Host "`nConfiguracao:" -ForegroundColor Yellow
Write-Host "  Base Path: $BasePath" -ForegroundColor Gray
Write-Host "  Grupo: $FullGroupName" -ForegroundColor Gray
Write-Host "  Pasta com acesso completo: $FullAccessFolderName" -ForegroundColor Gray
Write-Host "  Total de pastas: $($FolderList.Count)" -ForegroundColor Gray

# Verificar se esta executando como Admin
$IsAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $IsAdmin) {
    Write-Host "`nERRO: Execute como Administrador!" -ForegroundColor Red
    exit 1
}

# Verificar se caminho base existe
if (-not (Test-PathExists $BasePath)) {
    Write-Host "`nERRO: Caminho base nao encontrado: $BasePath" -ForegroundColor Red
    exit 1
}

Write-Host "`n[OK] Administrador OK" -ForegroundColor Green
Write-Host "[OK] Caminho base validado" -ForegroundColor Green
Write-Host "`nProcessando pastas...`n" -ForegroundColor Yellow

# ===== PROCESSAR PASTAS =====

$SuccessCount = 0
$ErrorCount = 0
$SkipCount = 0

foreach ($FolderName in $FolderList) {
    $FolderPath = Join-Path -Path $BasePath -ChildPath $FolderName
    $FullAccessPath = Join-Path -Path $FolderPath -ChildPath $FullAccessFolderName
    
    Write-Host "PROCESSANDO: $FolderName"
    
    # Verificar se pasta existe
    if (-not (Test-PathExists $FolderPath)) {
        Write-Host "  [SKIP] Pasta nao existe" -ForegroundColor Yellow
        $SkipCount++
        continue
    }
    
    # 1. Configurar pasta principal (ReadAndExecute - sem heranca)
    Write-Host "  1. Configurando ReadAndExecute (sem heranca)..." -ForegroundColor Gray
    if (Set-ReadOnlyFolderPermission -FolderPath $FolderPath -GroupName $FullGroupName) {
        Write-Host "     [OK]" -ForegroundColor Green
    }
    else {
        Write-Host "     [ERRO]" -ForegroundColor Red
        $ErrorCount++
        continue
    }
    
    # Verificar se pasta de acesso completo existe
    if (-not (Test-PathExists $FullAccessPath)) {
        Write-Host "  2. [SKIP] Pasta '$FullAccessFolderName' nao existe" -ForegroundColor Yellow
        continue
    }
    
    # 2. Configurar pasta de acesso completo (Modify - com heranca)
    Write-Host "  2. Configurando $FullAccessFolderName (Modify, com heranca)..." -ForegroundColor Gray
    if (Set-FullAccessFolderPermission -FolderPath $FullAccessPath -GroupName $FullGroupName) {
        Write-Host "     [OK]" -ForegroundColor Green
        $SuccessCount++
    }
    else {
        Write-Host "     [ERRO]" -ForegroundColor Red
        $ErrorCount++
    }
    
    Write-Host ""
}

# ===== RESUMO FINAL =====

Write-Host "=" * 80 -ForegroundColor Gray
Write-Host "`nRESUMO" -ForegroundColor Cyan
Write-Host "  Pastas configuradas com sucesso: $SuccessCount" -ForegroundColor Green
Write-Host "  Pastas nao encontradas: $SkipCount" -ForegroundColor Yellow
Write-Host "  Erros: $ErrorCount" -ForegroundColor $(if ($ErrorCount -gt 0) { "Red" } else { "Green" })

Write-Host "`n[OK] SCRIPT FINALIZADO!" -ForegroundColor Green
Write-Host "`nPermissoes aplicadas:" -ForegroundColor Cyan
Write-Host "  - Pasta principal: ReadAndExecute (sem heranca)" -ForegroundColor Gray
Write-Host "  - Subpasta '$FullAccessFolderName': Modify (com heranca)" -ForegroundColor Gray
Write-Host "  - Demais subpastas: Sem acesso" -ForegroundColor Gray
