Setup Azure Security centre for Virtual machine, SQL Server and App Services
============================================================================

This ARM template can be used to enable security centre protection for Azure
Virtual machine, Azure SQL Server and Azure app services.

Need to provide custom Log Analytics Workspace, SubscriptionID and Resource
group to setup the settings for security centre.

Also it helps to setup autoProvisioning of Microsoft monitoring Agent(MMA)
extension for the Azure resources and Alert notification of Azure Security
Centre (ASC).

Deployment Instructions
-----------------------

If you want to deploy this template, please make sure you target the subscription instead of a resource group, since ASC lives at the subscription level, not at the resource group level.

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

-   Run the given below command to deploy the template.

-   Change the name and location values according to your requirement.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ powershell
New-AzDeployment -Name deploymentname -Location EastUS -TemplateFile template.json -TemplateParameterFile parameters.json
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

-   Run the given below command to deploy the template.

-   Change the name and location values according to your requirement. 

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ powershell
az deployment create  --name deploymentname  --location eastus  --template-file template.json  --parameters parameters.json
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

### Deploy To Azure

Subscription level template deployment can not be done by Azure Portal.
