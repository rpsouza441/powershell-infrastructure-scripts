# PowerShell Infrastructure Scripts

Este repositório contém uma coleção de scripts e ferramentas em PowerShell desenvolvidos para auxiliar na administração, automação e gerenciamento de infraestrutura de TI.

O objetivo é centralizar soluções para tarefas comuns de SysAdmin, DevOps e suporte, promovendo padronização e eficiência.

## Estrutura do Repositório

Os scripts estão organizados por categorias em diretórios específicos:

### 📂 [permissions](./permissions)
Scripts relacionados ao gerenciamento de permissões de arquivos e pastas (NTFS/Share).
- **Set-Granular-Folder-Permissions.ps1**: Configura permissões granulares (Leitura na raiz, Modificação em subpastas) para grupos específicos.

## Como Contribuir

1.  Mantenha os scripts organizados na pasta da categoria correspondente.
2.  Sempre inclua comentários explicativos e cabeçalhos nos scripts.
3.  Evite hardcoding de informações sensíveis (senhas, nomes de servidores específicos, dados de clientes) - use parâmetros ou variáveis genéricas.
4.  Atualize o README da pasta específica ao adicionar novos scripts.

## Requisitos Gerais

- Windows PowerShell 5.1 ou PowerShell Core (7+).
- Privilégios administrativos podem ser necessários para a maioria dos scripts de infraestrutura.