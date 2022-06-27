# Azure ContainerApp as cloud development stack 

## Overview
A simple Bicep module who allows to deploy an development ContainerApp environement.
It will deploy the following resources:
- An Azure Premium storage account optimized for File share
- An Azure File Share with SMB filesystem
- A ContainerApp env with the Azure file share as filesystem
- A ContainerAPP application with VSCode server up and ready with port binded as 443 and password enabled



## How it works

An Azure File Share will be used by the ContainerApp environment and it will shared as volume by ContainerAPP images.
All you have to do is to deploy some images in containerapps env and bind volumes. An example is provided in `app.bicep`
You need to have `az` (azure cli) up and running.

To deploy the stack, run:

`az deployment create --template-file modules.bicep -l <YOUR-LOCATION> `