param location string = resourceGroup().location
param appContainerEnvironmentEnvId string

resource app 'Microsoft.App/containerApps@2022-03-01' = {
  name: 'app'
  location: location
  properties: {
    managedEnvironmentId: appContainerEnvironmentEnvId
    configuration: {
      ingress: {
        external: true
        targetPort: 80
        transport: 'auto'
      }
    }
    template: {
      containers: [
        {
          image: 'aaveline/node:v1'
          name: 'app'
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
          storageName: 'aymericstorage'
          storageType: 'AzureFile'
        }
      ]
    }
  }
}
