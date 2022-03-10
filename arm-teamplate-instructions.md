# Instructions to setup the environment

1. Go to Azure Portal, search by "Deploy a custom template" 
2. Select template > Build your own template in the editor
3. Copy the content from [az-sentinel.json](az-sentinel.json), paste into the editor then save.
4. On Resource Group, create a new one then click to **Review + Create**
5. Repeat the steps 1-2, copy the content from  [environment-template.json](environment-template.json), paste into the editor and save
10. On **Resource group** choose the same proviously created. For **Diagnostics Workspace Name** type **azuresentinel-arm**, for **Diagnostics Workspace Subscription** insert your Subscription ID and for **Diagnostics Workspace Resource Group** type the same resource group previoulsy created.
11. Click to **Review + Create**
12. Setup Kali Linux following [this instructions](kali.md)
