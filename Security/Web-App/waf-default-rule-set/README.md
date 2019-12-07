Azure Front door service based Security protection of Azure Web app - Default ruleset
=====================================================================================

Azure WAF provides centralized protection for web applications that are globally
delivered using Azure Front Door. It is designed to defend web services against
common exploits and vulnerabilities and keep these services highly available for
your users in addition to meeting compliance requirements.

Default ruleset
---------------

It helps to enable Default Firewall ruleset for the web app using front door web
application firewall policy.

You can configure custom rules based on string matching HTTP/HTTPS request
parameters such as query strings, POST args, Request URI, Request Header, and
Request Body.

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