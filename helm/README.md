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
