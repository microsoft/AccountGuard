Azure Front door service based Security protection of Azure Web app - Geo filtering
===================================================================================

Azure WAF provides centralized protection for web applications that are globally
delivered using Azure Front Door. It is designed to defend web services against
common exploits and vulnerabilities and keep these services highly available for
your users in addition to meeting compliance requirements.

Geo filtering
-------------

This template is to help setup a rule to Allow/Block/Log geographic specifc web
app traffic.

[Country codes list which we can use for Geo Filtering](https://msdn.microsoft.com/library/mt761717.aspx)

Deployment Instructions
-----------------------

### Azure PowerShell CmdLet

-   Download the ARM template and parameter file.

-   Keep your template.json (Main template) and parameters.json in the local
    folder.

-   Update the parameter.json file to suit your requirements.

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

-   Update the parameter.json file to suit your requirements.

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

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FMicrosoft%2FAccountGuard%2Fmaster%2FSecurity%2FWeb-App%2Fwaf-geo-filtering%2Ftemplate.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png" title="Open Azure Portal and Deploy Template"/> 
</a>
