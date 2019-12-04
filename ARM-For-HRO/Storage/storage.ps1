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
