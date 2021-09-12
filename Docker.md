# Installing Docker

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

    Run the following command

    ```console
    newgrp docker
    ```

    to update group information in the current session. Alternatively, you can simply re-login.

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
