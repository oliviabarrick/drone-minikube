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

# set docker settings
#echo "export DOCKER_HOST='tcp://127.0.0.1:2375'" >> /etc/profile
# reread all config
#source /etc/profile

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
    # this for loop waits until kubectl can access the api server that Minikube has created
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

    if [[ -d "/kube_specs" ]]; then
        echo "### Apply kubernetes specs..."
        kubectl apply -R -f /kube_specs/
    fi

    echo "### Minikube is ready."
    minikube logs -f
fi

exec "$@"
