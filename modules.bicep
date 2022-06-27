targetScope = 'subscription'

@minLength(3)
@maxLength(11)
param namePrefix string
param location string = deployment().location

var resourceGroupName = '${namePrefix}rg'

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName
  location: location
}

module main './modules/main.bicep' = {
  scope: rg
  name: 'main'
  params: {
    location: location
    namePrefix: namePrefix
  }
}

output mainFqdn string = main.outputs.fqdn
/*
  ------------------
  Append your module
  ------------------
  module app './modules/app.bicep' = {
    scope: rg
    name: 'app'
    dependsOn: [ main ]
    params: {
      location: location
      appContainerEnvironmentEnvId: main.outputs.containerAppEnvId
    }
  }

  */
