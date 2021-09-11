# Setup in traefik as ingress controller using yaml

This approach will configure Traefik as ingress using yaml files.

References:

## Configuring Traefik ingress

References:

- [https://doc.traefik.io/traefik/v1.7/user-guide/kubernetes/](https://doc.traefik.io/traefik/v1.7/user-guide/kubernetes/)
- [https://kubernetes.io/docs/tasks/access-application-cluster/ingress-minikube/](https://kubernetes.io/docs/tasks/access-application-cluster/ingress-minikube/)

1. If you are using *minikube*, confirm that ingress addon is enabled

    ```console
    minikube addons enable ingress
    ```

1. Create a namespace to run the deployments

    ```console
    kubectl create namespace traefik-yaml
    ```

1. Deploy the app in the namespace.

    ```console
    helm install tr-webapp ./tr-webapp --namespace traefik-yaml
    ```

1. Three yaml files are required to configure the ingress access:

    *[rbac.yaml](./traefik-yaml/rbac.yaml)*:

    ```yaml
    ---
    kind: ClusterRole
    apiVersion: rbac.authorization.k8s.io/v1beta1
    metadata:
    name: traefik-ingress-controller
    rules:
    - apiGroups:
        - ""
        resources:
        - services
        - endpoints
        - secrets
        verbs:
        - get
        - list
        - watch
    - apiGroups:
        - extensions
        - networking.k8s.io
        resources:
        - ingresses
        - ingressclasses
        verbs:
        - get
        - list
        - watch
    - apiGroups:
        - extensions
        resources:
        - ingresses/status
        verbs:
        - update

    ---
    kind: ClusterRoleBinding
    apiVersion: rbac.authorization.k8s.io/v1beta1
    metadata:
    name: traefik-ingress-controller
    roleRef:
    apiGroup: rbac.authorization.k8s.io
    kind: ClusterRole
    name: traefik-ingress-controller
    subjects:
    - kind: ServiceAccount
        name: traefik-ingress-controller
        namespace: default
    ```

    *[traefik.yaml](./traefik-yaml/traefik.yaml)*:

    ```yaml
    apiVersion: v1
    kind: ServiceAccount
    metadata:
    name: traefik-ingress-controller

    ---
    kind: Deployment
    apiVersion: apps/v1
    metadata:
    name: traefik
    labels:
        app: traefik

    spec:
    replicas: 1
    selector:
        matchLabels:
        app: traefik
    template:
        metadata:
        labels:
            app: traefik
        spec:
        serviceAccountName: traefik-ingress-controller
        containers:
            - name: traefik
            image: traefik:v2.3
            args:
                - --entrypoints.web.address=:80
                - --providers.kubernetesingress
            ports:
                - name: web
                containerPort: 80

    ---
    apiVersion: v1
    kind: Service
    metadata:
    name: traefik
    spec:
    type: LoadBalancer
    selector:
        app: traefik
    ports:
        - protocol: TCP
        port: 80
        name: web
        targetPort: 80
    ```

    *[ingress.yaml](./traefik-yaml/ingress.yaml)*:

    ```yaml
    kind: Ingress
    apiVersion: networking.k8s.io/v1beta1
    metadata:
    name: myingress
    annotations:
        traefik.ingress.kubernetes.io/router.entrypoints: web

    spec:
    rules:
        - host: hello-world.traefik-yaml
        http:
            paths:
            - path: /
                backend:
                serviceName: tr-webapp
                servicePort: 8080
    ```

1. Apply the files:

    ```console
    [roberto@vmlab01 traefik-yaml]$ kubectl apply -f rbac.yaml --namespace traefik-yaml

    Warning: rbac.authorization.k8s.io/v1beta1 ClusterRole is deprecated in v1.17+, unavailable in v1.22+; use rbac.authorization.k8s.io/v1 ClusterRole
    clusterrole.rbac.authorization.k8s.io/traefik-ingress-controller unchanged
    Warning: rbac.authorization.k8s.io/v1beta1 ClusterRoleBinding is deprecated in v1.17+, unavailable in v1.22+; use rbac.authorization.k8s.io/v1 ClusterRoleBinding
    clusterrolebinding.rbac.authorization.k8s.io/traefik-ingress-controller unchanged
    ```

    ```console
    [roberto@vmlab01 traefik-yaml]$ kubectl apply -f traefik.yaml --namespace traefik-yaml

    serviceaccount/traefik-ingress-controller created
    deployment.apps/traefik created
    service/traefik created
    ```

    ```console
    [roberto@vmlab01 traefik-yaml]$ kubectl apply -f ingress.yaml --namespace traefik-yaml
    Warning: networking.k8s.io/v1beta1 Ingress is deprecated in v1.19+, unavailable in v1.22+; use networking.k8s.io/v1 Ingress
    ingress.networking.k8s.io/myingress created
    ```

1. Check service and ingress resources

    ```console
    [roberto@vmlab01 traefik-yaml]$ kubectl get svc --namespace traefik-yaml
    NAME        TYPE           CLUSTER-IP       EXTERNAL-IP   PORT(S)          AGE
    tr-webapp   NodePort       10.101.197.48    <none>        8080:31808/TCP   17m
    traefik     LoadBalancer   10.103.172.100   <pending>     80:30320/TCP     11m
    ```

    ```console
    [roberto@vmlab01 traefik-yaml]$ kubectl get ingress --namespace traefik-yaml
    NAME        CLASS    HOSTS                      ADDRESS        PORTS   AGE
    myingress   <none>   hello-world.traefik-yaml   192.168.49.2   80      10m
    ```

    (you should wait a few seconds until "ADDRESS" list an IP address for the ingress resource)

1. Create a static entry in /etc/hosts to point to the new hostname hello-world.trafik-yaml

    ```console
    sudo echo "192.168.49.2 hello-world.traefik-yaml" >> /etc/hosts
    ```

1. Now you should be able to access the url:

    ```console
    [roberto@vmlab01 traefik-yaml]$ curl hello-world.traefik-yaml
    Hello World
    ```
