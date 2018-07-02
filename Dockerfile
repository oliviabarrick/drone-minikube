FROM jrei/systemd-debian
MAINTAINER Presslabs <ping@presslabs.com>
 
EXPOSE 8443
WORKDIR /root

RUN apt-get update && apt-get install -y apt-transport-https ca-certificates curl gnupg2 software-properties-common sudo && \
    curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add - && \
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian stretch stable" && \
    apt-get update && apt-get install -y docker-ce

ARG KUBE_VERSION=1.10.0
ARG MINIKUBE_VERSION=0.28.0

ENV KUBERNETES_VERSION="${KUBE_VERSION}" \
    MINIKUBE_WANTUPDATENOTIFICATION="false" \
    MINIKUBE_WANTREPORTERRORPROMPT="false" \
    MINIKUBE_HOME="/root" \
    MINIKUBE_CACHE="/root/.minikube/cache/v${KUBE_VERSION}" \
    CHANGE_MINIKUBE_NONE_USER="true"

RUN curl "https://github.com/kubernetes/minikube/releases/download/v${MINIKUBE_VERSION}/minikube-linux-amd64" -o /usr/local/bin/minikube -L

RUN mkdir -p ${MINIKUBE_CACHE} && \
    curl "https://storage.googleapis.com/kubernetes-release/release/v${KUBERNETES_VERSION}/bin/linux/amd64/kubectl" -o /usr/local/bin/kubectl && \
    curl "https://storage.googleapis.com/kubernetes-release/release/v${KUBERNETES_VERSION}/bin/linux/amd64/kubelet" -o ${MINIKUBE_CACHE}/kubelet && \
    curl "https://storage.googleapis.com/kubernetes-release/release/v${KUBERNETES_VERSION}/bin/linux/amd64/kubeadm" -o /usr/local/bin/real-kubeadm && \
    chmod +x /usr/local/bin/kubectl /usr/local/bin/minikube ${MINIKUBE_CACHE}/kubelet /usr/local/bin/real-kubeadm

ENTRYPOINT ["/lib/systemd/systemd"]

COPY kubeadm.sh ${MINIKUBE_CACHE}/kubeadm
COPY docker.override /etc/systemd/system/docker.service.d/override.conf
COPY minikube.service /etc/systemd/system/minikube.service
RUN systemctl enable minikube.service

VOLUME /root/.minikube
