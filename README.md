# Deploy a static web page helm and traefik

The purpose of this lab is to develop a full provisioned pipeline to deploy a static web page.

You can clone [this](https://github.com/rjrpaz/deploy-using-helm) repository to get some of the files that are we going to use during the lab.

## Objectives

1. Build your own Docker image that can serve a static "Hello World" HTML page

1. Deploy that image as a container in a Kubernetes cluster running locally on your machine using helm and writing your own chart

1. Deploy a Traefik container in the same local Kubernetes cluster using helm

1. Make Traefik an ingress point to access the "Hello World" page

1. Make the "Hello World" page accessible locally at [http://hello-world.local](http://hello-world.local)

## Requirements

For the purpose of this lab we are going to use a CentOS 7.

### Pre-requisite tools

We are going to use the following tools (click in the link to see how to install each tool):

- [Docker](./Docker.md)

- [Kubernetes](./Kubernetes.md)

- [Helm](./Helm.md)

## Build of the components

All required files and scripts for this deployment are included in this project.

- How to create the docker image: [./docker/README.md](./docker/README.md)

- How to create the helm chart: [./helm/README.md](./helm/README.md)

## Deploy the app

References:

- [https://doc.traefik.io/traefik/v2.3/routing/providers/kubernetes-ingress/](https://doc.traefik.io/traefik/v2.3/routing/providers/kubernetes-ingress/)

- [https://doc.traefik.io/traefik/v1.7/user-guide/kubernetes/](https://doc.traefik.io/traefik/v1.7/user-guide/kubernetes/) (this is from a previous version of trafik but the idea is basically the same)

These are the required steps, assuming you already have all required tools already installed.

1. Clone this project in an empty directory

    ```console
    git clone https://github.com/rjrpaz/deploy-using-helm.git
    cd deploy-using-helm
    ```

1. Assure that ingress addon for minikube is already installed

    ```console
    minikube addons enable ingress
    ```

1. Create a namespace

    ```console
    kubectl create namespace tr-webapp-ns
    ```

1. Install the app using the chart:

    ```console
    helm install tr-webapp ./helm/tr-webapp --namespace tr-webapp-ns
    ```

1. Install traefik

    1. Add helm repo for *traefik*

        ```console
        helm repo add traefik https://helm.traefik.io/traefik
        ```

    1. Update helm

        ```console
        helm repo update
        ```

    1. Install traefik

        ```console
        helm install traefik traefik/traefik --namespace tr-webapp-ns
        ```

1. List pods in the namespace to check status

    ```console
    kubectl get pods --namespace tr-webapp-ns
    ```

    It should return at least two running pods (our app and traefik service):

    ```console
    NAME                         READY   STATUS    RESTARTS   AGE
    tr-webapp-86b97d69cc-znpvl   1/1     Running   0          4m6s
    traefik-7594596bbc-6mzg9     1/1     Running   0          39s
    ```

1. Apply the ingress file:

    ```console
    kubectl apply -f helm/ingress.yaml --namespace tr-webapp-ns
    ```

1. Check service resources

    ```console
    kubectl get svc --namespace tr-webapp-ns
    ```

    It should return something like this:

    ```console
    NAME        TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)                      AGE
    tr-webapp   NodePort       10.103.93.206   <none>        8080:32422/TCP               9m53s
    traefik     LoadBalancer   10.96.143.228   <pending>     80:31004/TCP,443:31250/TCP   8m16s
    ```

1. Check ingress resources

    ```console
    kubectl get ingress --namespace tr-webapp-ns
    ```

    It should return something like this:

    ```console
    NAME        CLASS    HOSTS               ADDRESS        PORTS   AGE
    myingress   <none>   hello-world.local   192.168.49.2   80      6m24s
    ```

    (you should wait a few seconds until "ADDRESS" list an IP address for the ingress resource)

1. Create a static entry in /etc/hosts to point to the new hostname hello-world.local

    ```console
    echo "$(minikube ip) hello-world.local" | sudo tee -a /etc/hosts
    ```

1. Check reachability to the url:

    ```console
    curl hello-world.local
    ```

    You should get a "Hello World" message

## Alternative solutions to the same issue

While I was investigating this, I tried some alternative solutions listed below:

- Use nginx ingress [here](./Nginx_ingress.md)

- Use traefik + yaml files [here](./Traefik-yaml.md)

## Next steps

- Get ingress plugin to work with a newest version of minikube (Current version: 1.23.0).

- Configure all services using a custom helm chart (remove yaml content).

- Upload the helm char to a public repository.

- Add scripts (ansible?, terraform?) to deploy the artifact.
