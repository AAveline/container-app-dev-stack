import { Construct } from "constructs";
import { App, TerraformStack } from "cdktf";
import { Container, Image, DockerProvider } from "@cdktf/provider-docker";

const app = new App();

class MyStack extends TerraformStack {
  constructor(scope: Construct, name: string) {
    super(scope, name);

    new DockerProvider(this, "docker", {});

    const dockerImage = new Image(this, "nginxImage", {
      name: "nginx:latest",
      keepLocally: false,
    });

    new Container(this, "nginxContainer", {
      name: "tutorial",
      image: dockerImage.latest,
      ports: [
        {
          internal: 80,
          external: 9000,
        },
      ],
    });
  }
}


// Instantiate stack  
new MyStack(app, "my-app");

export default app;