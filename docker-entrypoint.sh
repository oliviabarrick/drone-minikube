#!/bin/sh

#clean pid after unexpected kill
if [ -f "/var/run/docker.pid" ]; then
		rm -rf /var/run/docker.pid
fi

echo "### Starting Docker Daemon..."
sudo dockerd \
        --host=unix:///var/run/docker.sock \
        --host=tcp://0.0.0.0:2375  \
        --storage-driver=vfs &

export DOCKER_HOST="tcp://127.0.0.1:2375"

sleep 2 # wait for docker demon to wake up

if [ "$GOOGLE_CREDENTIALS" = "" ]; then
    echo "### Login to docker to gcr.io ..."
    sudo docker login -u _json_key -p "$GOOGLE_CREDENTIALS" https://gcr.io
fi

if [ "$DOCKER_USER" = "" ]; then
    echo "### Login to docker to gcr.io ..."
    sudo docker login -u "$DOCKER_USER" -p "$DOCKER_PASSWORD"
fi

if [ "$1" == "start" ]; then
    echo "### Starting minikube (k8s version: $KUBERNETES_VERSION)..."
    sudo minikube start \
        --kubernetes-version=v${KUBERNETES_VERSION} \
        --extra-config=apiserver.Audit.LogOptions.Path="/var/log/apiserver/audit.log" \
        --extra-config=apiserver.Audit.LogOptions.MaxAge=30 \
        --extra-config=apiserver.Audit.LogOptions.MaxSize=100 \
        --extra-config=apiserver.Audit.LogOptions.MaxBackups=5 \
        --bootstrapper=localkube \
        --vm-driver=none

    echo "### Setting kubeconfig context..."
    sudo minikube update-context

    echo "### Waiting for minkube to be ready..."
    # waits for api server to be up
    set +e
    j=0
    while [ $j -le 150 ]; do
        kubectl get po &> /dev/null
        if [ $? -ne 1 ]; then
            break
        fi
        sleep 2
        j=$(( j + 1 ))
    done
    set -e

    echo "### Minikube is ready."

    if [ -d "$DRONE_WORKSPACE" ]; then
        base=${DRONE_WORKSPACE:1}
        base="/${base%%/*}"
        echo "### Deploy .kube to $base ..."

        cp -r /root/.kube $base/.kube.orig
        cp /root/.minikube/client.* $base/.kube.orig/
        cp /root/.minikube/ca.crt $base/.kube.orig/

        # replace new path in config
        sed -i "s/\/root\/.minikube/\\$base\/.kube/g" $base/.kube.orig/config
        chmod o+r -R $base/.kube.orig
        mv $base/.kube.orig $base/.kube
    fi

    minikube logs -f
fi

exec "$@"
