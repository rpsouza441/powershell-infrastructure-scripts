# Scripts de Permissões

Este diretório contém scripts PowerShell para automação e gerenciamento de permissões em sistemas de arquivos Windows (NTFS).

## Set-Granular-Folder-Permissions.ps1

Este script foi desenvolvido para configurar permissões granulares em uma estrutura de pastas específica, garantindo que um grupo de usuários tenha acesso restrito na raiz e acesso total em subpastas designadas.

### Funcionalidades

O script aplica a seguinte lógica de permissões:

1.  **Pasta Pai (Raiz do Cliente/Projeto):**
    *   Permissão: `ReadAndExecute` (Leitura e Execução).
    *   Herança: **Desativada** (Não propaga para subpastas automaticamente, exceto onde especificado).
    *   Objetivo: Permitir que o usuário navegue até a subpasta de trabalho sem visualizar ou alterar outros conteúdos da raiz.

2.  **Subpasta Específica (ex: "Financeiro", "Tributário"):**
    *   Permissão: `Modify` (Modificação - Leitura, Escrita, Exclusão).
    *   Herança: **Ativada** (Propaga para arquivos e subpastas dentro dela).
    *   Objetivo: Permitir trabalho irrestrito dentro desta pasta específica.

### Pré-requisitos

*   **Privilégios:** O script deve ser executado como **Administrador**.
*   **Ambiente:** Windows com PowerShell 5.1 ou superior.

### Configuração

Antes de executar, edite a seção de configurações no início do script:

```powershell
# Caminho raiz onde as pastas dos clientes/projetos estão localizadas
$BasePath = "C:\Caminho\Para\Pasta_Base"

# Nome do grupo no AD (sem o domínio)
$GroupName = "Nome_Do_Grupo"

# Domínio do Active Directory
$DomainName = "SEU_DOMINIO"

# Nome da subpasta que receberá permissão de Modificação
$FullAccessFolderName = "Nome_Subpasta_Acesso_Total"

# Lista de pastas onde as permissões serão aplicadas
$FolderList = @(
    "Cliente_A",
    "Cliente_B"
)
```

### Como Executar

1.  Abra o PowerShell como Administrador.
2.  Navegue até o diretório do script.
3.  Execute:
    ```powershell
    .\Set-Granular-Folder-Permissions.ps1
    ```

### Autor

*   Pinheiro
