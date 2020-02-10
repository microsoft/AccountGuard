SECURING THE DATA IN AN AZURE STORAGE ACCOUNT USING CUSTOMER-MANAGED KEYS STORED IN AZURE KEYVAULT
==================================================================================================

Introduction
------------

The purpose of this document is to provide instructions on how to create a storage account in Azure and encrypt the data using secured keys stored in Azure KeyVault. 
We will be using Azure PowerShell Cmdlets to accomplish this.

Below are the step-by-step instructions and an explanation of each step. You will also find a complete powershell script to implement the code in your Azure Infrastruture. 

Instructions
------------

### Step 1: Define Variables

First step is to define the Resource group, Storage account name, Key vault
name, Azure location, SKU and Key name values using variables.

#### Make sure to change the values of the variables

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ powershell
###########variables############

$msresourcegroupname= "gaudemo"
$msstorageaccountname= "pssecstorageaccount"
$mskeyvaultname="pskeyvault"
$msAzureLocation= "westus"
$msSkuname="Standard_GRS"
$mskeyname="DBCustomerKey"
###########variables############
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

### Step 2: Connect to your Azure Subscription using Azure PowerShell.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ powershell
Connect-AzAccount
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

### Step 3: Create a Storage account using variables defined above.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ powershell
try
{
    # create a storage account       
    $storageAccount = New-AzStorageAccount -ResourceGroupName $msresourcegroupname -AccountName $msstorageaccountname -Location $msAzureLocation -SkuName $msSkuname -AssignIdentity
}
catch
{
    Write-Host "An error occurred:"
    Write-Host $_
}
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Above script creates a storage account in a resource group.

### Step 4: Create a Key Vault in your Azure Subscription.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ powershell
if  ($null -ne $storageAccount)
{
    try
    {    
        $keyVault = New-AzKeyVault -Name $mskeyvaultname -ResourceGroupName $msresourcegroupname -Location $msAzureLocation -EnableSoftDelete -EnablePurgeProtection
    }
    catch
    {
        Write-Host "An error occurred for New-AzKeyVault "
        Write-Host $_
    }
}
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Please note that for customer-managed encryption keys to work, both the KeyVault
and Storage Account must be in the same region.

### Step 5: Setup an access policy for the Azure KeyVault created in Step 4.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ powershell
if  ($null -ne $keyVault)
{
    Set-AzKeyVaultAccessPolicy  -VaultName $keyVault.VaultName -ObjectId $storageAccount.Identity.PrincipalId -PermissionsToKeys wrapkey,unwrapkey,get,recover
}
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

### Step 6: Create a key in the KeyVault created in Step 4.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ powershell
try
{
    $key = Add-AzKeyVaultKey -VaultName $keyVault.VaultName -Name $mskeyname -Destination 'Software'
}
catch
{
    Write-Host "An error occurred while Add-AzKeyVaultKey"
    Write-Host $_
}
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

This is the key with which the data stored in Blobs and Files Service will be
encrypted.

### Step 7: Update the storage account to use the key created in Step 6 for encryption.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ powershell
if ( $null -ne $storageAccount -and  $null -ne $key  -and $null -ne $keyVault)
{
    try
    {
        Set-AzStorageAccount -ResourceGroupName $storageAccount.ResourceGroupName -AccountName $storageAccount.StorageAccountName -KeyvaultEncryption -KeyName $key.Name -KeyVersion $key.Version -KeyVaultUri $keyVault.VaultUri
    }
    catch
    {
        Write-Host "An error occurred while Set-AzStorageAccount"
        Write-Host $_
     }
}
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Complete Code
-------------

Here’s the complete PowerShell code.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ powershell
<#

Using this implementing the best security practices create the Key vault based Storage account to keep the data at rest encrypted using customer key

Important
Using customer-managed keys with Azure Storage encryption requires that two properties be set on the key vault, Soft Delete and Do Not Purge. These properties are not enabled by default. To enable these properties, use either PowerShell or Azure CLI. Only RSA keys and key size 2048 are supported.
#>

###########variables############

$msresourcegroupname= "gaudemo"
$msstorageaccountname= "pssecstorageaccount"
$mskeyvaultname="pskeyvault"
$msAzureLocation= "westus"
$msSkuname="Standard_GRS"
$mskeyname="DBCustomerKey"
###########variables############

Connect-AzAccount

try
{
    # create a storage account       
    $storageAccount = New-AzStorageAccount -ResourceGroupName $msresourcegroupname -AccountName $msstorageaccountname -Location $msAzureLocation -SkuName $msSkuname -AssignIdentity
}
catch
{
    Write-Host "An error occurred:"
    Write-Host $_
}

# Set-AzStorageAccount -ResourceGroupName $msresourcegroupname -Name $msstorageaccountname
if ($null -ne $storageAccount )
{
    try
    {    
        $keyVault = New-AzKeyVault -Name $mskeyvaultname -ResourceGroupName $msresourcegroupname -Location $msAzureLocation -EnableSoftDelete -EnablePurgeProtection
    }
    catch
    {
        Write-Host "An error occurred for New-AzKeyVault "
        Write-Host $_
    }

    if ($null -ne $keyVault)
    {
        Set-AzKeyVaultAccessPolicy  -VaultName $keyVault.VaultName -ObjectId $storageAccount.Identity.PrincipalId -PermissionsToKeys wrapkey,unwrapkey,get,recover
        try
        {
            $key = Add-AzKeyVaultKey -VaultName $keyVault.VaultName -Name $mskeyname -Destination 'Software'
        }
        catch
        {
             Write-Host "An error occurred while Add-AzKeyVaultKey"
             Write-Host $_
        }
        if ($null -ne $storageAccount -and  $null -ne $key  -and $null -ne $keyVault)
        {
            try
            {
                Set-AzStorageAccount -ResourceGroupName $storageAccount.ResourceGroupName -AccountName $storageAccount.StorageAccountName -KeyvaultEncryption -KeyName $key.Name -KeyVersion $key.Version -KeyVaultUri $keyVault.VaultUri
            }
            catch
            {
                Write-Host "An error occurred while Set-AzStorageAccount"
                Write-Host $_
             }
         }
    }
}
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
