param location string = resourceGroup().location
param namePrefix string

var logAnalyticsWorkspaceName = 'logs-${appContainerEnvironmentName}'
var appInsightsName = 'appins-${appContainerEnvironmentName}'
var appContainerEnvironmentName = '${namePrefix}containerappenv'

var storageAccountName = '${namePrefix}storageaccount'
var fileShareName = '${namePrefix}storage'

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-09-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Premium_LRS'
  }
  kind: 'FileStorage'
  properties: {

  }
}

resource fileShare 'Microsoft.Storage/storageAccounts/fileServices/shares@2021-09-01' = {
  name: '${storageAccount.name}/default/${fileShareName}'
  properties: {
    enabledProtocols: 'SMB'
    shareQuota: 100
  }
}

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-03-01-preview' = {
  name: logAnalyticsWorkspaceName
  location: location
  properties: any({
    retentionInDays: 30
    features: {
      searchVersion: 1
    }
    sku: {
      name: 'PerGB2018'
    }
  })
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightsName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalyticsWorkspace.id
  }
}

resource appContainerEnvironment 'Microsoft.App/managedEnvironments@2022-03-01' = {
  name: appContainerEnvironmentName
  location: location
  properties: {
    daprAIInstrumentationKey: reference(appInsights.id, '2020-02-02').InstrumentationKey
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: reference(logAnalyticsWorkspace.id, '2020-03-01-preview').customerId
        sharedKey: listKeys(logAnalyticsWorkspace.id, '2020-03-01-preview').primarySharedKey
      }
    }
  }
}

resource appContainerEnvironmentShare 'Microsoft.App/managedEnvironments/storages@2022-03-01' = {
  name: '${appContainerEnvironmentName}/${namePrefix}storage'
  dependsOn: [
    appContainerEnvironment
  ]
  properties: {
    azureFile: {
      accessMode: 'ReadWrite'
      accountKey: storageAccount.listKeys().keys[0].value
      accountName: storageAccountName
      shareName: fileShareName
    }
  }
}

resource vsCodeApp 'Microsoft.App/containerApps@2022-03-01' = {
  name: 'vscode-app'
  location: location
  dependsOn: [ appContainerEnvironmentShare ]
  properties: {
    managedEnvironmentId: appContainerEnvironment.id
    configuration: {
      ingress: {
        external: true
        targetPort: 8443
        transport: 'auto'
      }
    }
    template: {
      containers: [
        {
          env: [
            {
              name: 'PASSWORD'
              value: 'password'
            }
            {
              name: 'PUID'
              value: '1000'
            }
            {
              name: 'PGID'
              value: '1000'
            }
            {
              name: 'SUDO_PASSWORD'
              value: 'password'
            }
          ]
          image: 'lscr.io/linuxserver/code-server:latest'
          name: 'vscode-app'
          volumeMounts: [
            {
              mountPath: '/config/workspace'
              volumeName: 'azure-files-volume'
            }
          ]
          resources: {
            cpu: 1
            memory: '2Gi'
          }
        }
      ]
      scale: {
        minReplicas: 1
        maxReplicas: 1
      }
      volumes: [
        {
          name: 'azure-files-volume'
          storageName: '${namePrefix}storage'
          storageType: 'AzureFile'
        }
      ]
    }
  }
}

output fqdn string = vsCodeApp.properties.configuration.ingress.fqdn
output containerAppEnvId string = appContainerEnvironment.id
