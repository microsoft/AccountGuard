Create VM Using ARM Template with End Point Protection
======================================================

 

Introduction
------------

Purpose of this document is to provide instructions on how to create a virtual
machine in Azure using ARM Template with end point protection. We will provide
step-by-step instructions on how to accomplish this with an explanation of what
is being done in a particular step. This will be followed by complete script.

 

Instructions
------------

Using the ARM template, with the help of Azure Portal can load the ARM template
and parameter file and create the Virtual machine with end point protection. In
the Azure portal, using Custom deployment option, using build your own template
option, load the main ARM template and Save it, then using Edit parameters
option -\> Load file, load the parameter file to fill all the parameter value,
then you can create the Virtual machine using ARM template. This ARM template
creates End point protected Microsoft Windows 2019 DataCenter edition OS with
given below specification

-   vCPU – 1

-   Memory GiB – 3.5 Temp Storage (SSD) GiB – 7

-   Max data disks – 4

-   Max cached and temp storage throughput: IOPS / MBps (cache size in GiB) -
    4000 / 32 (43)

-   Max uncached disk throughput: IOPS / MBps - 3200 / 48

-   Max NICs / Expected network bandwidth (Mbps) - 2 / 750

-   OS Disk type - Premium_LRS

-   Public IP Address SKU – Basic

-   Public IP Address Type – Dynamic

-   Location – EastUS

-   Boot Diagnostics enabled

 

End Point protection section:
-----------------------------

The following Antimalware configuration template settings must be adjusted for
your **Azure Cloud Service application** per your application requirements. Only
supported Antimalware configuration settings are allowed.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ powershell
{
    "type": "Microsoft.Resources/deployments",
    "apiVersion": "2015-01-01",
    "name": "microsoft.antimalware-windows-deployment",
    "dependsOn": [
        "[concat('Microsoft.Compute/virtualMachines/', parameters('vmName'))]"
    ],
    "properties": {
        "mode": "incremental",
        "templateLink": {
            "uri": "https://gallery.azure.com/artifact/20161101/microsoft.antimalware-windows-arm.1.0.2/Artifacts/MainTemplate.json"
        },
        "parameters": {
            "vmName": {
                "value": "[parameters('vmName')]"
            },
            "location": {
                "value": "[parameters('location')]"
            },
            "ExclusionsPaths": {
                "value": "c:\\Logs\\"
            },
            "ExclusionsExtensions": {
                "value": "c:\\Logs\\"
            },
            "RealtimeProtectionEnabled": {
                "value": "true"
            },
            "ScheduledScanSettingsIsEnabled": {
                "value": "true"
            },
            "ScheduledScanSettingsScanType": {
                "value": "Full"
            },
            "ScheduledScanSettingsDay": {
                "value": "7"
            },
            "ScheduledScanSettingsTime": {
                "value": "120"
            }
        }
    }
}
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

 

Complete code
-------------

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ powershell
{
    "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "diagnosticsStorageAccountType": {
            "defaultValue": "Standard_LRS",
            "allowedValues": [
                "Standard_LRS",
                "Standard_GRS",
                "Standard_ZRS",
                "Premium_LRS"
            ],
            "type": "String",
            "metadata": {
                "description": "Diagnostics Storage Account type"
            }
        },
        "publicIPAddressName": {
            "type": "String",
            "metadata": {
                "description": "Public IP Address Name"
            }
        },
        "publicIPAddressType": {
            "defaultValue": "Dynamic",
            "allowedValues": [
                "Dynamic",
                "Static"
            ],
            "type": "String",
            "metadata": {
                "description": "Type of public IP address"
            }
        },
        "networkSecurityGroupName": {
            "defaultValue": "default-nsg",
            "type": "String",
            "metadata": {
                "description": "Network security group name"
            }
        },
        "virtualNetworkName": {
            "type": "String",
            "metadata": {
                "description": "VNET Name"
            }
        },
        "addressPrefix": {
            "defaultValue": "10.0.0.0/16",
            "type": "String",
            "metadata": {
                "description": "VNET address space"
            }
        },
        "subnetName": {
            "defaultValue": "default",
            "type": "String",
            "metadata": {
                "description": "Subnet name"
            }
        },
        "subnetPrefix": {
            "defaultValue": "10.0.0.0/24",
            "type": "String",
            "metadata": {
                "description": "Subnet address space"
            }
        },
        "networkInterfaceName": {
            "type": "String",
            "metadata": {
                "description": "Network interface name"
            }
        },
        "vmName": {
            "type": "String",
            "metadata": {
                "description": "Name of the VM"
            }
        },
        "vmSize": {
            "type": "String",
            "metadata": {
                "description": "Size of the VM"
            }
        },
        "osDiskType": {
            "defaultValue": "Premium_LRS",
            "type": "String",
            "metadata": {
                "description": "OS Disk Type"
            }
        },
        "imagePublisher": {
            "defaultValue": "MicrosoftWindowsServer",
            "type": "String",
            "metadata": {
                "description": "Image Publisher"
            }
        },
        "imageOffer": {
            "defaultValue": "WindowsServer",
            "type": "String",
            "metadata": {
                "description": "Image Offer"
            }
        },
        "imageSKU": {
            "defaultValue": "2019-Datacenter",
            "type": "String",
            "metadata": {
                "description": "Image SKU"
            }
        },
        "adminUsername": {
            "type": "String",
            "metadata": {
                "description": "Admin username"
            }
        },
        "adminPassword": {
            "type": "SecureString",
            "metadata": {
                "description": "Admin password"
            }
        },
        "location": {
            "defaultValue": "[resourceGroup().location]",
            "type": "String",
            "metadata": {
                "description": "Location for all resources."
            }
        }
    },
    "variables": {
        "diagnosticsStorageAccountName": "[concat(uniquestring(resourceGroup().id),'storage')]",
        "nsgId": "[resourceId(resourceGroup().name, 'Microsoft.Network/networkSecurityGroups', parameters('networkSecurityGroupName'))]",
        "vnetId": "[resourceId('Microsoft.Network/virtualNetworks',parameters('virtualNetworkName'))]",
        "subnetRef": "[concat(variables('vnetId'),'/subnets/',parameters('subnetName'))]"
    },
    "resources": [
        {
            "type": "Microsoft.Storage/storageAccounts",
            "apiVersion": "2019-06-01",
            "name": "[variables('diagnosticsStorageAccountName')]",
            "location": "[parameters('location')]",
            "sku": {
                "name": "[parameters('diagnosticsStorageAccountType')]"
            },
            "kind": "StorageV2",
            "properties": {}
        },
        {
            "type": "Microsoft.Network/publicIPAddresses",
            "apiVersion": "2019-02-01",
            "name": "[parameters('publicIPAddressName')]",
            "location": "[parameters('location')]",
            "properties": {
                "publicIPAllocationMethod": "[parameters('publicIPAddressType')]"
            }
        },
        {
            "type": "Microsoft.Network/networkSecurityGroups",
            "apiVersion": "2019-02-01",
            "name": "[parameters('networkSecurityGroupName')]",
            "location": "[parameters('location')]",
            "properties": {
                "securityRules": [
                    {
                        "name": "default-allow-3389",
                        "properties": {
                            "priority": 1000,
                            "access": "Allow",
                            "direction": "Inbound",
                            "destinationPortRange": "3389",
                            "protocol": "Tcp",
                            "sourcePortRange": "*",
                            "sourceAddressPrefix": "*",
                            "destinationAddressPrefix": "*"
                        }
                    }
                ]
            }
        },
        {
            "type": "Microsoft.Network/virtualNetworks",
            "apiVersion": "2019-04-01",
            "name": "[parameters('virtualNetworkName')]",
            "location": "[parameters('location')]",
            "properties": {
                "addressSpace": {
                    "addressPrefixes": [
                        "[parameters('addressPrefix')]"
                    ]
                },
                "subnets": [
                    {
                        "name": "[parameters('subnetName')]",
                        "properties": {
                            "addressPrefix": "[parameters('subnetPrefix')]"
                        }
                    }
                ]
            }
        },
        {
            "type": "Microsoft.Network/networkInterfaces",
            "apiVersion": "2019-07-01",
            "name": "[parameters('networkInterfaceName')]",
            "location": "[parameters('location')]",
            "dependsOn": [
                "[concat('Microsoft.Network/networkSecurityGroups/', parameters('networkSecurityGroupName'))]",
                "[concat('Microsoft.Network/publicIPAddresses/', parameters('publicIPAddressName'))]",
                "[concat('Microsoft.Network/virtualNetworks/', parameters('virtualNetworkName'))]"
            ],
            "properties": {
                "ipConfigurations": [
                    {
                        "name": "ipconfig1",
                        "properties": {
                            "privateIPAllocationMethod": "Dynamic",
                            "publicIPAddress": {
                                "id": "[resourceId('Microsoft.Network/publicIPAddresses',parameters('publicIPAddressName'))]"
                            },
                            "subnet": {
                                "id": "[variables('subnetRef')]"
                            }
                        }
                    }
                ],
                "networkSecurityGroup": {
                    "id": "[variables('nsgId')]"
                }
            }
        },
        {
            "type": "Microsoft.Compute/virtualMachines",
            "apiVersion": "2019-07-01",
            "name": "[parameters('vmName')]",
            "location": "[parameters('location')]",
            "dependsOn": [
                "[concat('Microsoft.Storage/storageAccounts/', variables('diagnosticsStorageAccountName'))]",
                "[concat('Microsoft.Network/networkInterfaces/', parameters('networkInterfaceName'))]"
            ],
            "properties": {
                "hardwareProfile": {
                    "vmSize": "[parameters('vmSize')]"
                },
                "osProfile": {
                    "computerName": "[parameters('vmName')]",
                    "adminUsername": "[parameters('adminUsername')]",
                    "adminPassword": "[parameters('adminPassword')]",
                    "windowsConfiguration": {
                        "enableAutomaticUpdates": true,
                        "provisionVmAgent": true
                    }
                },
                "storageProfile": {
                    "imageReference": {
                        "publisher": "[parameters('imagePublisher')]",
                        "offer": "[parameters('imageOffer')]",
                        "sku": "[parameters('imageSKU')]",
                        "version": "latest"
                    },
                    "osDisk": {
                        "createOption": "fromImage",
                        "managedDisk": {
                            "storageAccountType": "[parameters('osDiskType')]"
                        }
                    }
                },
                "networkProfile": {
                    "networkInterfaces": [
                        {
                            "id": "[resourceId('Microsoft.Network/networkInterfaces',parameters('networkInterfaceName'))]"
                        }
                    ]
                },
                "licenseType": "Windows_Server",
                "diagnosticsProfile": {
                    "bootDiagnostics": {
                        "enabled": true,
                        "storageUri": "[reference(resourceId('Microsoft.Storage/storageAccounts/', variables('diagnosticsStorageAccountName'))).primaryEndpoints.blob]"
                    }
                }
            }
        },
        {
            "type": "Microsoft.Resources/deployments",
            "apiVersion": "2015-01-01",
            "name": "microsoft.antimalware-windows-deployment",
            "dependsOn": [
                "[concat('Microsoft.Compute/virtualMachines/', parameters('vmName'))]"
            ],
            "properties": {
                "mode": "incremental",
                "templateLink": {
                    "uri": "https://gallery.azure.com/artifact/20161101/microsoft.antimalware-windows-arm.1.0.2/Artifacts/MainTemplate.json"
                },
                "parameters": {
                    "vmName": {
                        "value": "[parameters('vmName')]"
                    },
                    "location": {
                        "value": "[parameters('location')]"
                    },
                    "ExclusionsPaths": {
                        "value": "c:\\Logs\\"
                    },
                    "ExclusionsExtensions": {
                        "value": "c:\\Logs\\"
                    },
                    "RealtimeProtectionEnabled": {
                        "value": "true"
                    },
                    "ScheduledScanSettingsIsEnabled": {
                        "value": "true"
                    },
                    "ScheduledScanSettingsScanType": {
                        "value": "Full"
                    },
                    "ScheduledScanSettingsDay": {
                        "value": "7"
                    },
                    "ScheduledScanSettingsTime": {
                        "value": "120"
                    }
                }
            }
        }
    ]
}


Parameters:
{
    "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentParameters.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "diagnosticsStorageAccountType": {
            "value": "Standard_LRS"
        },
        "publicIPAddressName": {
            "value": "eppvmdemo-ip"
        },
        "publicIPAddressType": {
            "value": "Dynamic"
        },
        "networkSecurityGroupName": {
            "value": "default-nsg"
        },
        "virtualNetworkName": {
            "value": "eppvmdemo-vnet"
        },
        "addressPrefix": {
            "value": "10.0.0.0/16"
        },
        "subnetName": {
            "value": "default"
        },
        "subnetPrefix": {
            "value": "10.0.0.0/24"
        },
        "networkInterfaceName": {
            "value": "eppvmdemo-nic"
        },
        "vmName": {
            "value": "eppvmdemo"
        },
        "vmSize": {
            "value": "Standard_DS1_v2"
        },
        "osDiskType": {
            "value": "Premium_LRS"
        },
        "imagePublisher": {
            "value": "MicrosoftWindowsServer"
        },
        "imageOffer": {
            "value": "WindowsServer"
        },
        "imageSKU": {
            "value": "2019-Datacenter"
        },
        "adminUsername": {
            "value": "eppadmin"
        },
        "adminPassword": {
            "value": null
        },
        "location": {
            "value": "eastus"
        }
    }
}


        
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Deployment Instructions
-----------------------

### Azure PowerShell CmdLet

-   Download the ARM template and parameter file

-   Keep your template.json (Main template) and parameters.json in the local
    folder.

-   Update the parameter.json file including Admin password.

-   Download Azure PowerShell Module from [Microsoft
    Site](https://docs.microsoft.com/en-us/powershell/azure/install-az-ps?view=azps-3.1.0)
    if it is not exists

-   In Azure PowerShell Command prompt move to the location where template and
    parameter files are located using *CD* command

-   Run the given below command to create the Virtual machine.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ powershell
New-AzResourceGroupDeployment -Name deploymentname -ResourceGroupName Resourcegroupname -TemplateFile template.json -TemplateParameterFile parameters.json
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

### Deploy from Azure Cloud shell

-   Download the ARM template and parameter file.

-   Keep your template.json (Main template) and parameters.json in the local
    folder.

-   Update the parameter.json file including Admin password.

-   Download Az CLI from [Microsoft
    Site](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)
    if it is not exists

-   Login Az CLI using *Az login* it opens the browser after successful browser
    login validation opens the session in Az CLI

-   In Command prompt move to the location where template and parameter files
    are located using *CD* command

-   Run the given below command to create the Virtual machine.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ powershell
az group deployment create  --name deploymentname  --resource-group Resourcegroupname  --template-file template.json  --parameters parameters.json
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

### Deploy To Azure

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FMicrosoft%2FAccountGuard%2Fmaster%2FSecurity%2FVirtual-Machine%2Ftemplate.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png" title="Open Azure Portal and Deploy Template"/> 
</a>
