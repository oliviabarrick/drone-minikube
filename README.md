# Minikube for drone as a service
This is image is used as a drone service to start a minkube, using docker in docker.

## Drone yaml example

```
pipeline:
  kubectl:
    image: wernight/kubectl
    environment:
      # set KUBECONFIG to allow connection to minikube
      # should be configured to the base workspace dir.
      - KUBECONFIG=/drone/.kube/config
    commands:
      - sleep 30  # wait for nodes to start
      - kubectl get no

services:
  minikube:
    image: presslabs/drone-minikube:v1.7.5
    privileged: true
```
