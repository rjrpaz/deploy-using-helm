# Deploy a static web page using an IaaC pipeline

The purpose of this lab is to develop a full provisioned pipeline to deploy a static web page.

## Objectives

1. Build your own Docker image that can serve a static "Hello World" HTML page

1. Deploy that image as a container in a Kubernetes cluster running locally on your machine using helm and writing your own chart

1. Deploy a Traefik container in the same local Kubernetes cluster using helm

1. Make Traefik an ingress point to access the "Hello World" page

1. Bonus: Make the "Hello World" page accessible locally at [http://hello-world.local](http://hello-world.local)

## Requirements

For the purpose of this lab we are going to use a CentOS 7. Instructions will also provide the installation of required tools.

### Pre-requisite tools

Install the following tools:

- docker

- kubernetes

- helm

#### Docker

Reference: [https://docs.docker.com/engine/install/centos/](https://docs.docker.com/engine/install/centos/)

1. Install yum-utils

    ```console
    sudo yum install -y yum-utils
    ```

1. Add docker repo

    ```console
    sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
    ```

1. Install docker engine

    ```console
    sudo yum install -y docker-ce docker-ce-cli containerd.io
    ```

1. Enable docker service

    ```console
    sudo systemctl enable --now docker
    ```

1. Check docker service status

    ```console
    sudo systemctl status docker
    ```

1. Create a docker group (if required)

    ```console
    sudo groupadd docker
    ```

1. Add your personal user to the docker group

    ```console
    sudo usermod -aG docker $USER
    ```

    You need to re-login for this last modification to be active.

1. Run a test to confirm docker is working

    ```console
    [roberto@vmlab01 ~]$ docker run hello-world

    Unable to find image 'hello-world:latest' locally
    latest: Pulling from library/hello-world
    b8dfde127a29: Pull complete
    Digest: sha256:7d91b69e04a9029b99f3585aaaccae2baa80bcf318f4a5d2165a9898cd2dc0a1
    Status: Downloaded newer image for hello-world:latest

    Hello from Docker!
       ...
    ```

1. If you get the following error when ran the previous command:

    *Got permission denied while trying to connect to the Docker daemon socket at unix:///var/run/docker.sock: Get "http://%2Fvar%2Frun%2Fdocker.sock/v1.24/version": dial unix /var/run/docker.sock: connect: permission denied*

    Run the following command:

    ```console
    sudo chgrp docker /var/run/docker.sock
    ```

    and try again

#### Kubernetes and related tools

References:

- [https://minikube.sigs.k8s.io/docs/start/](https://minikube.sigs.k8s.io/docs/start/)

- [https://kubernetes.io/docs/tasks/tools/](https://kubernetes.io/docs/tasks/tools/)

- [https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/)

1. Install **minikube**

    ```console
    sudo curl -o /usr/local/sbin/minikube -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
    ```

1. Add execution permissions to the binary

    ```console
    sudo chmod ugo+x /usr/local/sbin/minikube
    ```

1. Start kubernetes cluster

    ```console
    minikube start
    ```

    (this may takes a few minutes)

1. Test health of kubernetes cluster

    ```console
    [roberto@vmlab01 Helm-test]$ minikube status
    minikube
    type: Control Plane
    host: Running
    kubelet: Running
    apiserver: Running
    kubeconfig: Configured
    ```

1. Install **kubectl**

    ```console
    sudo curl -o /usr/local/bin/kubectl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    ```

1. Add execution permissions to the binary

    ```console
    sudo chmod ugo+x /usr/local/bin/kubectl
    ```

1. Check communication with cluster

    ```console
    [roberto@vmlab01 Helm-test]$ kubectl get nodes
    NAME       STATUS   ROLES                  AGE   VERSION
    minikube   Ready    control-plane,master   72s   v1.22.1
    ```

#### Helm

References:

- [https://helm.sh/docs/intro/install/](https://helm.sh/docs/intro/install/)

1. Download helm package

    ```console
    wget https://get.helm.sh/helm-v3.7.0-rc.2-linux-amd64.tar.gz
    ```

1. Unpack the downloaded package

    ```console
    tar -zxvf helm-v3.7.0-rc.2-linux-amd64.tar.gz
    ```

1. Copy the binary to a proper destination

    ```console
    sudo cp linux-amd64/helm /usr/local/bin/
    ```

1. Add execution permissions to the binary (if needed)

    ```console
    sudo chmod ugo+x /usr/local/bin/helm
    ```

1. Test the command

    ```console
    [roberto@vmlab01 ~]$ helm help
    The Kubernetes package manager

    Common actions for Helm:

    - helm search:    search for charts
    - helm pull:      download a chart to your local directory to view
    - helm install:   upload the chart to Kubernetes
    - helm list:      list releases of charts
        ...
    ```

## Deployment step by step

All required files and scripts for this deployment are stored here: [https://github.com/rjrpaz/deploy-using-helm](https://github.com/rjrpaz/deploy-using-helm)

You can clone this repository to avoid unnecesary typing:

```console
git clone https://github.com/rjrpaz/deploy-using-helm.git
```

I will use my docker user (rjrpaz) for tagging and uploading the image to the registry. I encourage you to replace this with your own user if you are trying to replicate these steps.

### Build your own Docker image that can serve a static "Hello World" HTML page

This image is created using a very simple *Dockerfile*.

1. Change to directory *deploy-using-helm*

    ```console
    cd deploy-using-helm/docker
    ```

    This is the content of Dockerfile:

    ```console
    [roberto@vmlab01 ]$ cat Dockerfile

    FROM nginx:1.21.1-alpine
    EXPOSE 80/tcp
    RUN echo "Hello World" > /usr/share/nginx/html/index.html
    ```

1. Build the docker image

    ```console
    docker build -t rjrpaz/tr-webapp:1.0.0 .
    ```

1. Run the container

    ```console
    docker run -p 8080:80 -d rjrpaz/tr-webapp:1.0.0
    ```

    Access to the following url [http://localhost:8080](http://localhost:8080). You should see something like this:

    ![Main page](./images/Challenge-01.PNG)

1. Stop the container

    ```console
    docker stop $(docker ps -a -q  --filter ancestor=rjrpaz/tr-webapp:1.0.0)
    ```

1. Use *docker ps* to confirm the container is not running anymore.

1. Before pushing this images to Docker hub, we have to login first:

    ```console
    [roberto@vmlab01 ]$ docker login
    Login with your Docker ID to push and pull images from Docker Hub. If you don't have a Docker ID, head over to https://hub.docker.com to create one.
    Username: rjrpaz
        ...
    Login Succeeded
    ```

1. Now we are allowed to push the image to the registry:

    ```console
    [roberto@vmlab01 ]$ docker push rjrpaz/tr-webapp:1.0.0
    The push refers to repository [docker.io/rjrpaz/tr-webapp]
    b2bad1512e02: Pushed
    45d993692050: Mounted from library/nginx
    1ea998b95474: Mounted from library/nginx
    95b99a5c3767: Mounted from library/nginx
    fc03e3cb8568: Mounted from library/nginx
    24934e5e6c61: Mounted from library/nginx
    e2eb06d8af82: Mounted from library/nginx
    1.0.0: digest: sha256:8979e04523669748441a58af0ea3547282ad7674133e7bd359b883da2cb4a7d0 size: 1775
    [roberto@vmlab01 ]$
    ```

1. We can also upload the same image using the "latest" tag:

    ```console
    docker tag rjrpaz/tr-webapp:1.0.0 rjrpaz/tr-webapp:latest
    ```

    ```console
    docker push rjrpaz/tr-webapp:latest
    ```

### Deploy docker image as a container in a local Kubernetes cluster using helm

To running this we are going to use an isolated namespace (*tr-webapp-ns*) in the cluster.

1. Create the cluster namespace

    ```console
    kubectl create namespace tr-webapp-ns
    ```

1. Create the helm char skeleton

    ```console
    helm create tr-webapp
    ```

1. Modify repository in file *tr-webapp/values.yaml*. Replace:

    ```console
    repository: nginx
    ```

    with:

    ```console
    repository: rjrpaz/tr-webapp
    ```

1. Modify tag in file *tr-webapp/values.yaml*. Replace:

    ```console
    tag: ""
    ```

    with:

    ```console
    tag: "1.0.0"
    ```

1. Check helm chart integrity:

    ```console
    [roberto@vmlab01 ]$ helm lint ./tr-webapp
    ==> Linting ./tr-webapp
    [INFO] Chart.yaml: icon is recommended

    1 chart(s) linted, 0 chart(s) failed
    ```

1. Install the image using this new chart:

    ```console
    [roberto@vmlab01 ]$ helm install tr-webapp ./tr-webapp --namespace tr-webapp-ns
    NAME: tr-webapp
    LAST DEPLOYED: Thu Sep  9 15:30:23 2021
    NAMESPACE: tr-webapp-ns
    STATUS: deployed
    REVISION: 1
    NOTES:
    1. Get the application URL by running these commands:
    export POD_NAME=$(kubectl get pods --namespace tr-webapp-ns -l "app.kubernetes.io/name=tr-webapp,app.kubernetes.io/instance=tr-webapp" -o jsonpath="{.items[0].metadata.name}")
    export CONTAINER_PORT=$(kubectl get pod --namespace tr-webapp-ns $POD_NAME -o jsonpath="{.spec.containers[0].ports[0].containerPort}")
    echo "Visit http://127.0.0.1:8080 to use your application"
    kubectl --namespace tr-webapp-ns port-forward $POD_NAME 8080:$CONTAINER_PORT
    ```

1. To test this image, we should run the command provided by previous step:

    ```console
    export POD_NAME=$(kubectl get pods --namespace tr-webapp-ns -l "app.kubernetes.io/name=tr-webapp,app.kubernetes.io/instance=tr-webapp" -o jsonpath="{.items[0].metadata.name}")
    export CONTAINER_PORT=$(kubectl get pod --namespace tr-webapp-ns $POD_NAME -o jsonpath="{.spec.containers[0].ports[0].containerPort}")
    kubectl --namespace tr-webapp-ns port-forward $POD_NAME 8080:$CONTAINER_PORT
    ```

1. Access to the same url [http://localhost:8080](http://localhost:8080) and you should see the same sample webpage as before:

    ```console
    [roberto@vmlab01 ~]$ curl http://127.0.0.1:8080
    Hello World
    ```

1. Press <kbd>Ctrl + C</kbd> to interrupt the port forwarding

### Deploy a Traefik container in the same local Kubernetes cluster using helm

For this step we are going to use a public helm repos.

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
    helm install traefik traefik/traefik --namespace hello-world
    ```

1. List pods in the namespace to check status

    ```console
    [roberto@vmlab01 ]$ kubectl get pods --namespace tr-webapp-ns
    NAME                         READY   STATUS    RESTARTS   AGE
    tr-webapp-7fd9455889-qqmql   1/1     Running   0          13m
    traefik-7499c455c-spr8b      1/1     Running   0          22s
    ```
