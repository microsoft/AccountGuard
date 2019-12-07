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
            "name": "microsoft.antimalware-windows-20191118162231",
            "apiVersion": "2015-01-01",
            "type": "Microsoft.Resources/deployments",
            "properties": {
                "mode": "incremental",
                "templateLink": {
                    "uri": "https://gallery.azure.com/artifact/20161101/microsoft.antimalware-windows-arm.1.0.2/Artifacts/MainTemplate.json"
                },
                "parameters": {
                    "vmName": {
                        "value": "eppvmdemo"
                    },
                    "location": {
                        "value": "eastus"
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
            },
            "dependsOn": [
                "[concat('Microsoft.Compute/virtualMachines/', parameters('virtualMachineName'))]"
            ]
        }
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

 

Complete code
-------------

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ powershell
{
    "$schema": "http://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "location": {
            "type": "string"
        },
        "networkInterfaceName": {
            "type": "string"
        },
        "networkSecurityGroupName": {
            "type": "string"
        },
        "networkSecurityGroupRules": {
            "type": "array"
        },
        "subnetName": {
            "type": "string"
        },
        "virtualNetworkName": {
            "type": "string"
        },
        "addressPrefixes": {
            "type": "array"
        },
        "subnets": {
            "type": "array"
        },
        "publicIpAddressName": {
            "type": "string"
        },
        "publicIpAddressType": {
            "type": "string"
        },
        "publicIpAddressSku": {
            "type": "string"
        },
        "virtualMachineName": {
            "type": "string"
        },
        "virtualMachineRG": {
            "type": "string"
        },
        "osDiskType": {
            "type": "string"
        },
        "virtualMachineSize": {
            "type": "string"
        },
        "adminUsername": {
            "type": "string"
        },
        "adminPassword": {
            "type": "secureString"
        },
        "diagnosticsStorageAccountName": {
            "type": "string"
        },
        "diagnosticsStorageAccountId": {
            "type": "string"
        },
        "diagnosticsStorageAccountType": {
            "type": "string"
        },
        "diagnosticsStorageAccountKind": {
            "type": "string"
        },
        "autoShutdownStatus": {
            "type": "string"
        },
        "autoShutdownTime": {
            "type": "string"
        },
        "autoShutdownTimeZone": {
            "type": "string"
        },
        "autoShutdownNotificationStatus": {
            "type": "string"
        },
        "autoShutdownNotificationLocale": {
            "type": "string"
        },
        "autoShutdownNotificationEmail": {
            "type": "string"
        }
    },
    "variables": {
        "nsgId": "[resourceId(resourceGroup().name, 'Microsoft.Network/networkSecurityGroups', parameters('networkSecurityGroupName'))]",
        "vnetId": "[resourceId(resourceGroup().name,'Microsoft.Network/virtualNetworks', parameters('virtualNetworkName'))]",
        "subnetRef": "[concat(variables('vnetId'), '/subnets/', parameters('subnetName'))]"
    },
    "resources": [
        {
            "name": "[parameters('networkInterfaceName')]",
            "type": "Microsoft.Network/networkInterfaces",
            "apiVersion": "2019-07-01",
            "location": "[parameters('location')]",
            "dependsOn": [
                "[concat('Microsoft.Network/networkSecurityGroups/', parameters('networkSecurityGroupName'))]",
                "[concat('Microsoft.Network/virtualNetworks/', parameters('virtualNetworkName'))]",
                "[concat('Microsoft.Network/publicIpAddresses/', parameters('publicIpAddressName'))]"
            ],
            "properties": {
                "ipConfigurations": [
                    {
                        "name": "ipconfig1",
                        "properties": {
                            "subnet": {
                                "id": "[variables('subnetRef')]"
                            },
                            "privateIPAllocationMethod": "Dynamic",
                            "publicIpAddress": {
                                "id": "[resourceId(resourceGroup().name, 'Microsoft.Network/publicIpAddresses', parameters('publicIpAddressName'))]"
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
            "name": "[parameters('networkSecurityGroupName')]",
            "type": "Microsoft.Network/networkSecurityGroups",
            "apiVersion": "2019-02-01",
            "location": "[parameters('location')]",
            "properties": {
                "securityRules": "[parameters('networkSecurityGroupRules')]"
            }
        },
        {
            "name": "[parameters('virtualNetworkName')]",
            "type": "Microsoft.Network/virtualNetworks",
            "apiVersion": "2019-04-01",
            "location": "[parameters('location')]",
            "properties": {
                "addressSpace": {
                    "addressPrefixes": "[parameters('addressPrefixes')]"
                },
                "subnets": "[parameters('subnets')]"
            }
        },
        {
            "name": "[parameters('publicIpAddressName')]",
            "type": "Microsoft.Network/publicIpAddresses",
            "apiVersion": "2019-02-01",
            "location": "[parameters('location')]",
            "properties": {
                "publicIpAllocationMethod": "[parameters('publicIpAddressType')]"
            },
            "sku": {
                "name": "[parameters('publicIpAddressSku')]"
            }
        },
        {
            "name": "[parameters('virtualMachineName')]",
            "type": "Microsoft.Compute/virtualMachines",
            "apiVersion": "2019-07-01",
            "location": "[parameters('location')]",
            "dependsOn": [
                "[concat('Microsoft.Network/networkInterfaces/', parameters('networkInterfaceName'))]",
                "[concat('Microsoft.Storage/storageAccounts/', parameters('diagnosticsStorageAccountName'))]"
            ],
            "properties": {
                "hardwareProfile": {
                    "vmSize": "[parameters('virtualMachineSize')]"
                },
                "storageProfile": {
                    "osDisk": {
                        "createOption": "fromImage",
                        "managedDisk": {
                            "storageAccountType": "[parameters('osDiskType')]"
                        }
                    },
                    "imageReference": {
                        "publisher": "MicrosoftWindowsServer",
                        "offer": "WindowsServer",
                        "sku": "2019-Datacenter",
                        "version": "latest"
                    }
                },
                "networkProfile": {
                    "networkInterfaces": [
                        {
                            "id": "[resourceId('Microsoft.Network/networkInterfaces', parameters('networkInterfaceName'))]"
                        }
                    ]
                },
                "osProfile": {
                    "computerName": "[parameters('virtualMachineName')]",
                    "adminUsername": "[parameters('adminUsername')]",
                    "adminPassword": "[parameters('adminPassword')]",
                    "windowsConfiguration": {
                        "enableAutomaticUpdates": true,
                        "provisionVmAgent": true
                    }
                },
                "licenseType": "Windows_Server",
                "diagnosticsProfile": {
                    "bootDiagnostics": {
                        "enabled": true,
                        "storageUri": "[concat('https://', parameters('diagnosticsStorageAccountName'), '.blob.core.windows.net/')]"
                    }
                }
            }
        },
        {
            "name": "[parameters('diagnosticsStorageAccountName')]",
            "type": "Microsoft.Storage/storageAccounts",
            "apiVersion": "2019-06-01",
            "location": "[parameters('location')]",
            "properties": {},
            "kind": "[parameters('diagnosticsStorageAccountKind')]",
            "sku": {
                "name": "[parameters('diagnosticsStorageAccountType')]"
            }
        },
        {
            "name": "[concat('shutdown-computevm-', parameters('virtualMachineName'))]",
            "type": "Microsoft.DevTestLab/schedules",
            "apiVersion": "2017-04-26-preview",
            "location": "[parameters('location')]",
            "dependsOn": [
                "[concat('Microsoft.Compute/virtualMachines/', parameters('virtualMachineName'))]"
            ],
            "properties": {
                "status": "[parameters('autoShutdownStatus')]",
                "taskType": "ComputeVmShutdownTask",
                "dailyRecurrence": {
                    "time": "[parameters('autoShutdownTime')]"
                },
                "timeZoneId": "[parameters('autoShutdownTimeZone')]",
                "targetResourceId": "[resourceId('Microsoft.Compute/virtualMachines', parameters('virtualMachineName'))]",
                "notificationSettings": {
                    "status": "[parameters('autoShutdownNotificationStatus')]",
                    "notificationLocale": "[parameters('autoShutdownNotificationLocale')]",
                    "timeInMinutes": "30",
                    "emailRecipient": "[parameters('autoShutdownNotificationEmail')]"
                }
            }
        },
        {
            "name": "microsoft.antimalware-windows-20191118162231",
            "apiVersion": "2015-01-01",
            "type": "Microsoft.Resources/deployments",
            "properties": {
                "mode": "incremental",
                "templateLink": {
                    "uri": "https://gallery.azure.com/artifact/20161101/microsoft.antimalware-windows-arm.1.0.2/Artifacts/MainTemplate.json"
                },
                "parameters": {
                    "vmName": {
                        "value": "eppvmdemo"
                    },
                    "location": {
                        "value": "eastus"
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
            },
            "dependsOn": [
                "[concat('Microsoft.Compute/virtualMachines/', parameters('virtualMachineName'))]"
            ]
        }
    ],
    "outputs": {
        "adminUsername": {
            "type": "string",
            "value": "[parameters('adminUsername')]"
        }
    }
}


Parameters:
{
    "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentParameters.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "location": {
            "value": "eastus"
        },
        "networkInterfaceName": {
            "value": "eppvmdemo743"
        },
        "networkSecurityGroupName": {
            "value": "eppvmdemo-nsg"
        },
        "networkSecurityGroupRules": {
            "value": [
                {
                    "name": "RDP",
                    "properties": {
                        "priority": 300,
                        "protocol": "TCP",
                        "access": "Allow",
                        "direction": "Inbound",
                        "sourceAddressPrefix": "*",
                        "sourcePortRange": "*",
                        "destinationAddressPrefix": "*",
                        "destinationPortRange": "3389"
                    }
                }
            ]
        },
        "subnetName": {
            "value": "default"
        },
        "virtualNetworkName": {
            "value": "RGEPPVM-vnet"
        },
        "addressPrefixes": {
            "value": [
                "10.0.0.0/24"
            ]
        },
        "subnets": {
            "value": [
                {
                    "name": "default",
                    "properties": {
                        "addressPrefix": "10.0.0.0/24"
                    }
                }
            ]
        },
        "publicIpAddressName": {
            "value": "eppvmdemo-ip"
        },
        "publicIpAddressType": {
            "value": "Dynamic"
        },
        "publicIpAddressSku": {
            "value": "Basic"
        },
        "virtualMachineName": {
            "value": "eppvmdemo"
        },
        "virtualMachineRG": {
            "value": "RGEPPVM"
        },
        "osDiskType": {
            "value": "Premium_LRS"
        },
        "virtualMachineSize": {
            "value": "Standard_DS1_v2"
        },
        "adminUsername": {
            "value": "eppadmin"
        },
        "adminPassword": {
            "value": null
        },
        "diagnosticsStorageAccountName": {
            "value": "rgeppvmdiag"
        },
        "diagnosticsStorageAccountId": {
            "value": "Microsoft.Storage/storageAccounts/rgeppvmdiag"
        },
        "diagnosticsStorageAccountType": {
            "value": "Standard_LRS"
        },
        "diagnosticsStorageAccountKind": {
            "value": "Storage"
        },
        "autoShutdownStatus": {
            "value": "Enabled"
        },
        "autoShutdownTime": {
            "value": "19:00"
        },
        "autoShutdownTimeZone": {
            "value": "UTC"
        },
        "autoShutdownNotificationStatus": {
            "value": "Enabled"
        },
        "autoShutdownNotificationLocale": {
            "value": "en"
        },
        "autoShutdownNotificationEmail": {
            "value": ""
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