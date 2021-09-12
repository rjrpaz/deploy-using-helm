# Create a helm chart for the app

References:

- [https://helm.sh/docs/chart_template_guide/values_files/](https://helm.sh/docs/chart_template_guide/values_files/)
- [https://helm.sh/docs/topics/charts/](https://helm.sh/docs/topics/charts/)
- [https://helm.sh/docs/chart_best_practices/](https://helm.sh/docs/chart_best_practices/)
- [https://helm.sh/docs/chart_template_guide/values_files/](https://helm.sh/docs/chart_template_guide/values_files/)
- [https://helm.sh/docs/chart_best_practices/labels/](https://helm.sh/docs/chart_best_practices/labels/)

1. Create the helm char skeleton

    ```console
    helm create tr-webapp
    ```

1. Modify *description* in file *tr-webapp/Chart.yaml*:

    ```console
    description: A Helm chart for Kubernetes
    ```

1. Comment *livenessProbe* and *readinessProbe* sections in file *tr-webapp/templates/deployment.yaml*:

    ```console
    #          livenessProbe:
    #            httpGet:
    #              path: /
    #              port: http
    #          readinessProbe:
    #            httpGet:
    #              path: /
    #              port: http
    ```

1. Modify a few variables in file *tr-webapp/values.yaml*:

    - repository: rjrpaz/tr-webapp
    - tag: "1.0.0"
    - name: "tr-webapp-svc"

1. Modify *service* section in file *tr-webapp/values.yaml*:

    ```console
    service:
      type: NodePort
      port: 8080
    ```

1. Modify *hosts* section in file *tr-webapp/values.yaml* (change *host* entry):

    ```console
        - host: hello-world.local
    ```

1. Check helm chart integrity:

    ```console
    [roberto@vmlab01 ]$ helm lint ./tr-webapp
    ==> Linting ./tr-webapp
    [INFO] Chart.yaml: icon is recommended

    1 chart(s) linted, 0 chart(s) failed
    ```

1. To test the app, install the service using this new chart:

    ```console
    [roberto@vmlab01 ]$ helm install tr-webapp ./tr-webapp
    NAME: tr-webapp
    LAST DEPLOYED: Thu Sep  9 15:30:23 2021
    NAMESPACE: default
    STATUS: deployed
    REVISION: 1
    NOTES:
    1. Get the application URL by running these commands:
    export POD_NAME=$(kubectl get pods -l "app.kubernetes.io/name=tr-webapp,app.kubernetes.io/instance=tr-webapp" -o jsonpath="{.items[0].metadata.name}")
    export CONTAINER_PORT=$(kubectl get pod $POD_NAME -o jsonpath="{.spec.containers[0].ports[0].containerPort}")
    echo "Visit http://127.0.0.1:8080 to use your application"
    kubectl port-forward $POD_NAME 8080:$CONTAINER_PORT
    ```

1. ... and run the command provided by previous step:

    ```console
    export POD_NAME=$(kubectl get pods -l "app.kubernetes.io/name=tr-webapp,app.kubernetes.io/instance=tr-webapp" -o jsonpath="{.items[0].metadata.name}")
    export CONTAINER_PORT=$(kubectl get pod $POD_NAME -o jsonpath="{.spec.containers[0].ports[0].containerPort}")
    kubectl port-forward $POD_NAME 8080:$CONTAINER_PORT
    ```

1. Access to the same url [http://localhost:8080](http://localhost:8080) and you should see the same sample webpage as before:

    ```console
    [roberto@vmlab01 ~]$ curl http://127.0.0.1:8080
    Hello World
    ```

1. Press <kbd>Ctrl + C</kbd> to interrupt the port forwarding

## Publishing the chart

References:

- [https://helm.sh/docs/topics/chart_repository/#github-pages-example](https://helm.sh/docs/topics/chart_repository/#github-pages-example)

We are going to use github pages as repository for the helm chart.

1. Create a *gh-pages* branch in the github repository:

1. Configure *Settings* --> *pages*. Enable gh-pages if needed and configure the root folder that will store the documentation. In this case, the root directory of the project will store the documentation and the package.

1. Change to root directory for the project and run:

    ```console
    helm package helm/tr-webapp
    ```

    this will create a helm package named *tr-webapp-0.1.0.tgz*.

1. Create index file for the package repository

    ```console
    helm repo index . --url http://www.robertopaz.com.ar/deploy-using-helm/
    ```

    this should generate a *index.yaml* file.

1. Upload the branch:

    ```console
    git push origin gh-pages
    ```

1. Now you can use this as a helm repo:

    Add the repo:

    ```console
    [dxcuser@vmlab01 ~]$ helm repo add tr-webapp https://www.robertopaz.com.ar/deploy-using-helm/
    "tr-webapp" has been added to your repositories
    ```

    Install the package:

    ```console
    [dxcuser@vmlab01 ~]$ helm install tr-webapp tr-webapp/tr-webapp

    NAME: tr-webapp
    LAST DEPLOYED: Sun Sep 12 16:52:52 2021
    NAMESPACE: default
    STATUS: deployed
    REVISION: 1
    NOTES:
    1. Get the application URL by running these commands:
    export NODE_PORT=$(kubectl get --namespace default -o jsonpath="{.spec.ports[0].nodePort}" services tr-webapp)
    export NODE_IP=$(kubectl get nodes --namespace default -o jsonpath="{.items[0].status.addresses[0].address}")
    echo http://$NODE_IP:$NODE_PORT
    ```

    List installed packages:

    ```console
    [dxcuser@vmlab01 ~]$ helm list
    NAME            NAMESPACE       REVISION        UPDATED                                  STATUS          CHART           APP VERSION
    tr-webapp       default         1               2021-09-12 16:52:52.413712448 -0400 EDT  deployed        tr-webapp-0.1.0 0.1.0
    ```

    Run last commands suggested from the installation and confirm the app is running:

    ```console
    [dxcuser@vmlab01 ~]$ export NODE_PORT=$(kubectl get --namespace default -o jsonpath="{.spec.ports[0].nodePort}" services tr-webapp)
    [dxcuser@vmlab01 ~]$ export NODE_IP=$(kubectl get nodes --namespace default -o jsonpath="{.items[0].status.addresses[0].address}")
    [dxcuser@vmlab01 ~]$ echo http://$NODE_IP:$NODE_PORT
    http://192.168.49.2:32086

    [dxcuser@vmlab01 ~]$ curl http://192.168.49.2:32086
    Hello World
    ```
