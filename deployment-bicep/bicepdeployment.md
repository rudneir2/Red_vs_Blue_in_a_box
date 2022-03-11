# Red vs Blue in a box - environment deployment using Bicep templates

## New to Bicep?
If you are new to Bicep, here is an overview to get you started: [What is Bicep?](https://docs.microsoft.com/azure/azure-resource-manager/bicep/overview?tabs=bicep). 

To deploy resources to Azure with Bicep, you need to install some tooling. The easiest way is to install the latest version of the Azure CLI or Azure PowerShell - [Deployment environment](https://docs.microsoft.com/azure/azure-resource-manager/bicep/install#deployment-environment). Both of these tools support Bicep templates.

If you want to edit deployment parameters and/or customize Bicep templates, it is recommended to use [VS Code and Bicep extension](https://docs.microsoft.com/azure/azure-resource-manager/bicep/install#vs-code-and-bicep-extension).


## Deploy Red environment

You will need to clone/copy this project from GitHub to environment where you want to deploy from. Contents of `.\deployment-bicep` folder are required to deploy Bicep templates.

### Deployment with Azure CLI:

1. Log into tenant/subscription where you want Red environment deployed
    
    `az login`
2. Following step needs to be executed **once** to accept kali-linux terms

    `az vm image terms accept --urn kali-linux:kali-linux:kali:2019.2.0`
3. Go to `.\deployment-bicep` Folder of this project. Consider modifying any parameter values for deployment. To deploy environment with default values run

    `az deployment sub create --location 'westeurope' --template-file .\mainRed.bicep`

### Deployment with PowerShell

1. Log into tenant/subscription where you want Red environment deployed
    
    `Connect-AzAccount`
2. Following step needs to be executed **once** to accept kali-linux terms

    `Get-AzMarketplaceTerms -Publisher "kali-linux" -Product "kali-linux" -Name "kali" | Set-AzMarketplaceTerms -Accept`
3. Go to `.\deployment-bicep` Folder of this project. Consider modifying any parameter values for deployment. To deploy environment with default values run

    `New-AzSubscriptionDeployment -Location 'westeurope' -TemplateFile .\mainRed.bicep`

## Deploy Blue environment

### Deployment with Azure CLI:

1. Log into tenant/subscription where you want Blue environment deployed (if using same subscription as for Red environment, skip logging in again)

    `az login`

2. Consider modifying any parameter values for deployment. To deploy environment with default values run

    `az deployment sub create --location 'westeurope' --template-file .\mainBlue.bicep`

### Deployment with PowerShell:

1. Log into tenant/subscription where you want Blue environment deployed (if using same subscription as for Red environment, skip logging in again)

    `Connect-AzAccount`

2. Consider modifying any parameter values for deployment. To deploy environment with default values run

    `New-AzSubscriptionDeployment -Location 'westeurope' -TemplateFile .\mainBlue.bicep`

## Verify deployment

After successful deployment of Red environment you should see outputs that will help you identify Public IP of Attacker (Red) Kali VM `outKaliLinuxPublicIP`. Use this address to ssh into Kali Linux VM. If you deployed with defaults, use following credentials: 
`user: svradmin`
`password: H@ppytimes123!`

After successful deployment of Blue environment you will get couple of outputs that will help you connect to Blue environment:
- Public IP of Azure Firewall: `outAzureFirewallPublicIP`
- Public IP of Azure Application Gateway: `outApplicationGatewayPublicIP`
- URL of WebApp to access it directly (bypass Application Gateway): `outWebAppURL`

To access Windows Server 2019 VM, RDP to `outAzureFirewallPublicIP` and use port `33890` as VM is DNAT-ed behind Azure Firewall. If deployed with defaults, use same credentials as when accessing Kali Linux VM.

To access Windows 10 VM, RDP to `outAzureFirewallPublicIP` and use port `33891` as VM is DNAT-ed behind Azure Firewall. If deployed with defaults, use same credentials as when accessing Kali Linux VM.

To access sample Web App behind Application Gateway with Web Application Firewall use `outApplicationGatewayPublicIP` IP. You can also try reaching Web App directly, bypassing Application Gateway with WAF on URL `outWebAppURL`.

## Post deployment steps

Kali Linux VM comes without xrdp service deployed. If you want to RDP into Kali Linux VM, login via ssh first and execute following commands (note this will take a few minutes):

```
wget --no-check-certificate https://http.kali.org/kali/pool/main/k/kali-archive-keyring/kali-archive-keyring_2022.1_all.deb
sudo apt install ./kali-archive-keyring_2022.1_all.deb
sudo apt-get update
sudo apt-get -y install xrdp
sudo systemctl enable xrdp
echo xfce4-session >~/.xsession
sudo service xrdp restart
```
After successful deployment you will be able to RDP into Kali Linux VM using same IP and set of credentials.

## Happy hacking!

If you want to learn more on Bicep, check out this great learning content on [MS Learn](https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/learn-bicep).