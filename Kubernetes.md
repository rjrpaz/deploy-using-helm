# Kubernetes and related tools

References:

- [https://minikube.sigs.k8s.io/docs/start/](https://minikube.sigs.k8s.io/docs/start/)

- [https://kubernetes.io/docs/tasks/tools/](https://kubernetes.io/docs/tasks/tools/)

- [https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/)

1. Install **minikube** (v.18.0)

    ```console
    sudo curl -o /usr/local/sbin/minikube -LO https://storage.googleapis.com/minikube/releases/v1.18.0/minikube-linux-amd64
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
