# Minikube for drone as a service
This is image is used as a drone service to start a minkube, using docker in docker.

## Drone yaml example
```
pipeline:
  kubectl:
    image: presslabs/kluster-toolbox
    environment:
      # set KUBECONFIG to allow connection to minikube
      # should be configured to the base workspace dir.
      - KUBECONFIG=/drone/.kube/config
    commands:
      # wait for nodes to start
      # or wait for $KUBECONFIG file to exist
      - sleep 30 
      - kubectl get no

services:
  minikube:
    image: presslabs/drone-minikube:v1.9.0
    privileged: true
```
