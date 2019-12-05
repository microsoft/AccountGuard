# Azure Managed Instance SQL - Bring your own Key (BYOK) setup using PowerShell

## Introduction

Protecting data at rest using encryption is highly essential, in addition **Bring your own key (BYOK)** increase the bench mark security and alleviate any compromise in cloud platform security design.

## Overview

Using PowerShell, in two phase approach, **setup up Azure Managed Instance SQL** and **Bring your own key(BYOK) key vault setup and set Transparent Data encryption Protector**

* Create Managed Instance SQL DB
* Bring your own key(BYOK) key vault setup and set Transparent Data encryption Protector
    * Connect to Azure
    * Create a new Key Vault
    * Set Key vault access policy
    * Set key vault network ruleset
    * Add a new key vault key
    * Add Key vault key to Azure DB
    * Set Transparent Data encryption Protector for

Please refer the given below complete PowerShell code.

## Create Managed Instance SQL DB (PowerShell)

```powershell
# The SubscriptionId in which to create these objects
$SubscriptionId = ''
# Set the resource group name and location for your managed instance
$resourceGroupName = "rgencryptedmandbdemo"
$location = "East US"
# Set the networking values for your managed instance
$vNetName = "myVnet-$(Get-Random)"
$vNetAddressPrefix = "10.0.0.0/16"
$defaultSubnetName = "myDefaultSubnet-$(Get-Random)"
$defaultSubnetAddressPrefix = "10.0.0.0/24"
$miSubnetName = "myMISubnet-$(Get-Random)"
$miSubnetAddressPrefix = "10.0.0.0/24"
#Set the managed instance name for the new managed instance
$instanceName = "myMIName-$(Get-Random)"
# Set the admin login and password for your managed instance
$miAdminSqlLogin = "SqlAdmin"
$miAdminSqlPassword = "ChangeYourAdminPassword1"
# Set the managed instance service tier, compute level, and license mode
$edition = "General Purpose"
$vCores = 8
$maxStorage = 256
$computeGeneration = "Gen4"
$license = "LicenseIncluded" #"BasePrice" or LicenseIncluded if you have don't have SQL Server licence that can be used for AHB discount


Connect-AzAccount

# Set subscription context
#Set-AzContext -SubscriptionId $subscriptionId

# Create a resource group
#$resourceGroup = New-AzResourceGroup -Name $resourceGroupName -Location $location

# Configure virtual network, subnets, network security group, and routing table
$virtualNetwork = New-AzVirtualNetwork `
                      -ResourceGroupName $resourceGroupName `
                      -Location $location `
                      -Name $vNetName `
                      -AddressPrefix $vNetAddressPrefix

                  Add-AzVirtualNetworkSubnetConfig `
                      -Name $miSubnetName `
                      -VirtualNetwork $virtualNetwork `
                      -AddressPrefix $miSubnetAddressPrefix `
                  | Set-AzVirtualNetwork

$virtualNetwork = Get-AzVirtualNetwork -Name $vNetName -ResourceGroupName $resourceGroupName

$miSubnetConfig = Get-AzVirtualNetworkSubnetConfig `
                        -Name $miSubnetName `
                        -VirtualNetwork $virtualNetwork

$miSubnetConfigId = $miSubnetConfig.Id

$networkSecurityGroupMiManagementService = New-AzNetworkSecurityGroup `
                      -Name 'myNetworkSecurityGroupMiManagementService' `
                      -ResourceGroupName $resourceGroupName `
                      -location $location

$routeTableMiManagementService = New-AzRouteTable `
                      -Name 'myRouteTableMiManagementService' `
                      -ResourceGroupName $resourceGroupName `
                      -location $location

Set-AzVirtualNetworkSubnetConfig `
                      -VirtualNetwork $virtualNetwork `
                      -Name $miSubnetName `
                      -AddressPrefix $miSubnetAddressPrefix `
                      -NetworkSecurityGroup $networkSecurityGroupMiManagementService `
                      -RouteTable $routeTableMiManagementService | `
                    Set-AzVirtualNetwork

Get-AzNetworkSecurityGroup `
                      -ResourceGroupName $resourceGroupName `
                      -Name "myNetworkSecurityGroupMiManagementService" `
                      | Add-AzNetworkSecurityRuleConfig `
                      -Priority 100 `
                      -Name "allow_management_inbound" `
                      -Access Allow `
                      -Protocol Tcp `
                      -Direction Inbound `
                      -SourcePortRange * `
                      -SourceAddressPrefix * `
                      -DestinationPortRange 9000,9003,1438,1440,1452 `
                      -DestinationAddressPrefix * `
                      | Add-AzNetworkSecurityRuleConfig `
                      -Priority 200 `
                      -Name "allow_misubnet_inbound" `
                      -Access Allow `
                      -Protocol * `
                      -Direction Inbound `
                      -SourcePortRange * `
                      -SourceAddressPrefix $miSubnetAddressPrefix `
                      -DestinationPortRange * `
                      -DestinationAddressPrefix * `
                      | Add-AzNetworkSecurityRuleConfig `
                      -Priority 300 `
                      -Name "allow_health_probe_inbound" `
                      -Access Allow `
                      -Protocol * `
                      -Direction Inbound `
                      -SourcePortRange * `
                      -SourceAddressPrefix AzureLoadBalancer `
                      -DestinationPortRange * `
                      -DestinationAddressPrefix * `
                      | Add-AzNetworkSecurityRuleConfig `
                      -Priority 1000 `
                      -Name "allow_tds_inbound" `
                      -Access Allow `
                      -Protocol Tcp `
                      -Direction Inbound `
                      -SourcePortRange * `
                      -SourceAddressPrefix VirtualNetwork `
                      -DestinationPortRange 1433 `
                      -DestinationAddressPrefix * `
                      | Add-AzNetworkSecurityRuleConfig `
                      -Priority 1100 `
                      -Name "allow_redirect_inbound" `
                      -Access Allow `
                      -Protocol Tcp `
                      -Direction Inbound `
                      -SourcePortRange * `
                      -SourceAddressPrefix VirtualNetwork `
                      -DestinationPortRange 11000-11999 `
                      -DestinationAddressPrefix * `
                      | Add-AzNetworkSecurityRuleConfig `
                      -Priority 4096 `
                      -Name "deny_all_inbound" `
                      -Access Deny `
                      -Protocol * `
                      -Direction Inbound `
                      -SourcePortRange * `
                      -SourceAddressPrefix * `
                      -DestinationPortRange * `
                      -DestinationAddressPrefix * `
                      | Add-AzNetworkSecurityRuleConfig `
                      -Priority 100 `
                      -Name "allow_management_outbound" `
                      -Access Allow `
                      -Protocol Tcp `
                      -Direction Outbound `
                      -SourcePortRange * `
                      -SourceAddressPrefix * `
                      -DestinationPortRange 80,443,12000 `
                      -DestinationAddressPrefix * `
                      | Add-AzNetworkSecurityRuleConfig `
                      -Priority 200 `
                      -Name "allow_misubnet_outbound" `
                      -Access Allow `
                      -Protocol * `
                      -Direction Outbound `
                      -SourcePortRange * `
                      -SourceAddressPrefix * `
                      -DestinationPortRange * `
                      -DestinationAddressPrefix $miSubnetAddressPrefix `
                      | Add-AzNetworkSecurityRuleConfig `
                      -Priority 4096 `
                      -Name "deny_all_outbound" `
                      -Access Deny `
                      -Protocol * `
                      -Direction Outbound `
                      -SourcePortRange * `
                      -SourceAddressPrefix * `
                      -DestinationPortRange * `
                      -DestinationAddressPrefix * `
                      | Set-AzNetworkSecurityGroup


Get-AzRouteTable `
                      -ResourceGroupName $resourceGroupName `
                      -Name "myRouteTableMiManagementService" `
                      | Add-AzRouteConfig `
                      -Name "ToManagedInstanceManagementService" `
                      -AddressPrefix 0.0.0.0/0 `
                      -NextHopType Internet `
                      | Add-AzRouteConfig `
                      -Name "ToLocalClusterNode" `
                      -AddressPrefix $miSubnetAddressPrefix `
                      -NextHopType VnetLocal `
                     | Set-AzRouteTable

# Create managed instance
New-AzSqlInstance -Name $instanceName `
                      -ResourceGroupName $resourceGroupName -Location $location -SubnetId $miSubnetConfigId `
                      -AdministratorCredential (Get-Credential) `
                      -StorageSizeInGB $maxStorage -VCore $vCores -Edition $edition `
                      -ComputeGeneration $computeGeneration -LicenseType $license

# This script will take a minimum of 3 hours to create a new managed instance in a new virtual network.
# A second managed instance is created much faster.

# Clean up deployment
# Remove-AzResourceGroup -ResourceGroupName $resourceGroupName

```

## Bring your own key(BYOK) key vault setup and set Transparent Data encryption Protector (PowerShell)

``` powershell
# You will need an existing Managed Instance as a prerequisite for completing this script.
# See https://docs.microsoft.com/en-us/azure/sql-database/scripts/sql-database-create-configure-managed-instance-powershell

# Log in to your Azure account:
Connect-AzAccount

# If there are multiple subscriptions, choose the one where AKV is created:
#Set-AzContext -SubscriptionId "subscription ID"

# Install the preview version of Az.Sql PowerShell package 1.1.1-preview if you are running this PowerShell locally (uncomment below):
# Install-Module -Name Az.Sql -RequiredVersion 1.1.1-preview -AllowPrerelease -Force

# 1. Create Resource and setup Azure Key Vault (skip if already done)

# Create Resource group (name the resource and specify the location)
$location = "East US" # specify the location
$resourcegroup = "rgencryptedmandbdemo" # specify a new RG name
#New-AzResourceGroup -Name $resourcegroup -Location $location

# Create new Azure Key Vault with a globally unique VaultName and soft-delete option turned on:
$vaultname = "encryptedmandbdemokvc" # specify a globally unique VaultName
$keyVault = New-AzKeyVault -VaultName $vaultname -ResourceGroupName $resourcegroup -Location $location -EnableSoftDelete -EnablePurgeProtection
#$keyVault = New-AzKeyVault -Name $mskeyvaultname -ResourceGroupName $msresourcegroupname -Location $msAzureLocation -EnableSoftDelete -EnablePurgeProtection

$MyManagedInstanceName ="myMIName-1425670529"
# Authorize Managed Instance to use the AKV (wrap/unwrap key and get public part of key, if public part exists):
$objectid = (Set-AzSqlInstance -ResourceGroupName $resourcegroup -Name $MyManagedInstanceName -AssignIdentity).Identity.PrincipalId
Set-AzKeyVaultAccessPolicy -BypassObjectIdValidation -VaultName $vaultname -ObjectId $objectid -PermissionsToKeys get,wrapKey,unwrapKey
#Set-AzKeyVaultAccessPolicy     -VaultName $keyVault.VaultName -ObjectId $storageAccount.Identity.PrincipalId -PermissionsToKeys wrapkey,unwrapkey,get,recover

# Allow access from trusted Azure services:
Update-AzKeyVaultNetworkRuleSet -VaultName $vaultname -Bypass AzureServices

# Turn the network rules ON by setting the default action to Deny:
#Update-AzKeyVaultNetworkRuleSet -VaultName $vaultname -DefaultAction Deny


# 2. Provide TDE Protector key (skip if already done)

# The recommended way is to import an existing key from a .pfx file. Replace "<PFX private key password>" with the actual password below:
#$keypath = "c:\some_path\mytdekey.pfx" # Supply your .pfx path and name
#$securepfxpwd = ConvertTo-SecureString -String "<PFX private key password>" -AsPlainText -Force
#$key = Add-AzKeyVaultKey -VaultName $vaultname -Name "MyTDEKey" -KeyFilePath $keypath -KeyFilePassword $securepfxpwd

# ...or get an existing key from the vault:
# $key = Get-AzKeyVaultKey -VaultName $vaultname -Name "MyTDEKey"
# define the key name
$mskeyname = "MyTDEKey"
# Alternatively, generate a new key directly in Azure Key Vault (recommended for test purposes only - uncomment below):
#$key = Add-AzKeyVaultKey -VaultName $vaultname -Name $mskeyname -Destination Software -Size 2048

$key = Add-AzKeyVaultKey -VaultName $keyVault.VaultName -Name $mskeyname -Destination 'Software'

# 3. Set up BYOK TDE on Managed Instance:
$MyManagedInstanceName ="myMIName-1425670529"
# Assign the key to the Managed Instance:
# $key = 'https://contoso.vault.azure.net/keys/contosokey/01234567890123456789012345678901'
Add-AzSqlInstanceKeyVaultKey -KeyId $key.id -InstanceName $MyManagedInstanceName -ResourceGroupName $resourcegroup

# Set TDE operation mode to BYOK:
Set-AzSqlInstanceTransparentDataEncryptionProtector -Type AzureKeyVault -InstanceName $MyManagedInstanceName -ResourceGroup $resourcegroup -KeyId $key.id

```
