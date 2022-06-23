import { Construct } from "constructs";
import { App, TerraformStack } from "cdktf";
import  { AzurermProvider, ResourceGroup, ServicePlan, ContainerGroup } from "@cdktf/provider-azurerm";

const app = new App();

class MyAzureStack extends TerraformStack {

 constructor(scope: Construct, name: string) {
  super(scope, name);

  new AzurermProvider(this, "azure", {
    features: {}
  });

  const rg = new ResourceGroup(this, "rg", {
    name: "aymericrg",
    location: "westeurope"
  });

  const appServicePlan = new ServicePlan(this, "app-service-plan", {
    location: rg.location,
    name: 'aymericappserviceplan',
    resourceGroupName: rg.name,
    osType: 'Linux',
    skuName: 'S2',

  })

  new ContainerGroup(this, "web-app-container", {
    location: rg.location,
    name: 'aymericcontainergroup',
    resourceGroupName: rg.name,
    osType: appServicePlan.osType,
    ipAddressType: 'Public',
    dnsNameLabel: 'aymeric',
    container: [
      {
        image: 'nginx',
        name: 'nginx',
        cpu: 0.5,
        memory: 1.5,
        ports: [
          {
            port: 80,
            protocol: 'TCP'
          }
        ]
      }
    ]
  })

  new ContainerGroup(this, "web-app-container-yoanna", {
    location: rg.location,
    name: 'yoannacontainergroup',
    resourceGroupName: rg.name,
    osType: appServicePlan.osType,
    ipAddressType: 'Public',
    dnsNameLabel: 'yoanna',
    container: [
      {
        image: 'nginx',
        name: 'nginx',
        cpu: 0.5,
        memory: 1.5,
        ports: [
          {
            port: 80,
            protocol: 'TCP'
          }
        ]
      }
    ]
  })
 } 
}

// Instantiate stack
new MyAzureStack(app, "my-azure-app");

export default app