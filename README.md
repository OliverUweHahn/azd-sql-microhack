# SQL Modernization MicroHack AZD deployment

This repository deploys the SQL Modernization MicroHack environment using
Azure Developer CLI and modular Bicep.

## Resources

- One resource group
- One VNet named `SQLHACK-SHARED-VNET`
- Managed Instance subnet: `10.0.1.0/24`
- Management subnet: `10.0.2.0/24`
- Team jump-server subnet: `10.0.3.0/24`
- Azure Bastion subnet: `10.0.4.0/24`
- Azure SQL Managed Instance with General Purpose v2 enabled
- SQL Server 2016 SP3 Developer on Windows Server 2016
- StorageV2 account with a private `backups` container
- 5 through 20 team VMs
- Team VM names `vm-TEAM01` through `vm-TEAM20`
- SSMS 22 on every team VM
- Azure Storage Explorer on every team VM
- Azure Bastion Basic
- No public IP addresses on the workshop VMs

## Prerequisites

- Azure Developer CLI
- Azure CLI
- PowerShell
- An Azure subscription with sufficient SQL MI and VM quota
- Permission to deploy the required Azure resource types
- Access to the SQL Server 2016 Marketplace image

Register the required resource providers when necessary:

```powershell
az provider register --namespace Microsoft.Compute
az provider register --namespace Microsoft.Network
az provider register --namespace Microsoft.Sql
az provider register --namespace Microsoft.Storage