# Helm

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
