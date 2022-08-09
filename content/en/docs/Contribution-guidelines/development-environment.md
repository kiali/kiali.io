---
title: "Development Environment"
description: "How to set up a development environment"
---


### Introduction

In this section it is explained how to set up a development environment:
- As described in [Arquitecture](/docs/architecture/architecture), we would need to have the Kiali dependencies running in an Openshift or Kubernetes
- We will use a port forward to access those services outside the cluster.
- We will have the project source running locally. In this case we will set up an IDE.
- Bookinfo application example will also be running on our cluster.

![development_environment](/images/documentation/contribution/development_environment.png)

### Prerrequisites 

- Development tools are installed:
  - [oc](https://docs.openshift.com/container-platform/4.7/cli_reference/openshift_cli/getting-started-cli.html) or [kubectl](https://kubernetes.io/es/docs/tasks/tools/)
  - [go](https://go.dev/)
  - [make](https://www.gnu.org/software/make/)
  - [npm](https://www.npmjs.com/)
  - [yarn](https://yarnpkg.com/)
- Istio and required services are running in Minikube or open shift. To install it following the above schema, it is possible to use the following scripts:
  - `hack/istio/install-istio-via-istioctl.sh`: Installs the latest Istio release into *istio-system* namespace along with the Prometheus, Grafana, and Jaeger addons.
  - `hack/istio/install-bookinfo-demo.sh`: Installs the Bookinfo demo that is found in the Istio release that was installed via the *hack/istio/install-istio-via-istioctl.sh* hack script.
    - Pass in `-tg` to also install a traffic generator that will send messages periodically into the Bookinfo demo.
    - If using Minikube and the `-tg` option, make sure you pass in the Minikube profile name via `-mp` if the profile name is not `minikube`.

### Port forward

Before the setup, we will need to do a port-forward of the services that kiali is using.

We can use the `hack/run-kiali.sh` script for this purpose. It can work without any options. Pass --help to see the options it takes. 

An example to run it following the above schema:

```shell
./run-kiali.sh -pg 13000:3000 -pp 19090:9090 -app 8080 -es false -iu http://127.0.0.1:15014
```


### Local Configuration File

The go process will require a configuration to point to these services and other specific configurations. 
This file will be places in ~/kiali/config.yaml, and referenced later by the GO local process. 

```yaml
{{% readfile file="/static/files/contribution_guide/config.yaml" %}}
```

### Local Processes 

In this section we will start the 3 local processes for kiali:
- kiali-core: The backend Go process
- kiali-ui: The frontend React process
- browser: The Javascript debugger process. 

We will need to fork the 3 kiali repositories, and then, clone them in a local folder:
- [Kiali](https://github.com/kiali/kiali)
- [Kiali-operator](https://github.com/kiali/kiali-operator)
- [Helm-charts](https://github.com/kiali/helm-charts)

In this example, we will create the configurations in the Jetbrains Golang IDE.

#### kiali-core
![kiali-core](/images/documentation/contribution/kiali-core.png)

#### kiali-ui
In order to forward the requests to the backend propertly, we will need to add the following line in kiali/frontend/package.json:
```json
"proxy": "http://localhost:8000",
```

![kiali-ui](/images/documentation/contribution/kiali-ui.png)

#### browser
![browser](/images/documentation/contribution/browser.png)

After running the 3 processes, we should be able to access Kiali GUI in localhost:3000

### Using VisualStudio Code

To run kiali in a debugger, a file "launch.json" should be created in your local kiali local repo's .vscode directory (e.g. home/source/kiali/kiali/.vscode/launch.json). The file should look like:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Launch Kiali to use hack script services",
      "type": "go",
      "request": "launch",
      "mode": "debug",
      "program": "${workspaceRoot}/kiali.go",
      "cwd": "${env:HOME}/tmp/run-kiali",
      "args": ["-config", "${env:HOME}/tmp/run-kiali/run-kiali-config.yaml"],
      "env": {
        "KUBERNETES_SERVICE_HOST": "127.0.0.1",
        "KUBERNETES_SERVICE_PORT": "8001",
        "LOG_LEVEL": "trace"
      }     
    }
  ]
}
```

run-kiali.sh should be started like this:

```
hack/run-kiali.sh --tmp-root-dir $HOME/tmp --enable-server false
```