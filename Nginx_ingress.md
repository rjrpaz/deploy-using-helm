# Setup in ingress with Nginx ingress controller

Nginx ingress is one of the common way to access a containerized service.

References:

## Configuring Nginx ingress

References:

- [https://kubernetes.io/docs/tasks/access-application-cluster/ingress-minikube/](https://kubernetes.io/docs/tasks/access-application-cluster/ingress-minikube/)

1. If you are using *minikube*, confirm that ingress addon is enabled

    ```console
    minikube addons enable ingress
    ```

1. If you are using *minikube*, confirm that ingress addon is enabled

    ```console
    minikube addons enable ingress
    ```

1. Create a namespace to run the deployments

    ```console
    kubectl create namespace ingress
    ```

1. Deploy the app in the namespace.

    ```console
    helm install tr-webapp ./tr-webapp --namespace ingress
    ```

1. Create a file (*ingress.yaml*) to apply ingress:

    ```yaml
    apiVersion: networking.k8s.io/v1
    kind: Ingress
    metadata:
    name: ingress
    annotations:
        nginx.ingress.kubernetes.io/rewrite-target: /$1
    spec:
    rules:
        - host: hello-world.ingress
        http:
            paths:
            - path: /
                pathType: Prefix
                backend:
                service:
                    name: tr-webapp
                    port:
                    number: 8080
    ```

1. Apply the new settings

    ```console
    kubectl apply -f ingress.yaml --namespace ingress
    ```

1. Check service and ingress resources

    ```console
    [roberto@vmlab01 ingress]$ kubectl get svc --namespace ingress
    NAME        TYPE       CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
    tr-webapp   NodePort   10.100.96.113   <none>        8080:31682/TCP   6m52s
    ```

    ```console
    [roberto@vmlab01 ingress]$ kubectl get ingress --namespace ingress
    NAME      CLASS    HOSTS                 ADDRESS        PORTS   AGE
    ingress   <none>   hello-world.ingress   192.168.49.2   80      4m4s
    ```

    (you should wait a few seconds until "ADDRESS" list an IP address for the ingress resource)

1. Create a static entry in /etc/hosts to point to the new hostname hello-world.ingress

    ```console
    sudo echo "192.168.49.2 hello-world.ingress" >> /etc/hosts
    ```

1. Now you should be able to access the url:

    ```console
    [roberto@vmlab01 ingress]$ curl hello-world.ingress
    Hello World
    ```
