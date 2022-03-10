Guide on how to deploy environment using Bicep templates will be updated here.

Deployment with Azure CLI:

Log into tenant/subscription where you want Red environment deployed
Following step needs to be executed once to accept kali-linux terms
az vm image terms accept --urn kali-linux:kali-linux:kali:2019.2.0
az deployment sub create --location 'westeurope' --template-file .\mainRed.bicep 

Log into tenant/subscription where you want Blue environment deployed (if using same subscription as for Red environment, skip logging in again)
az deployment sub create --location 'westeurope' --template-file .\mainBlue.bicep