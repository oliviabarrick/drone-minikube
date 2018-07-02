#!/bin/bash

if [ "$1" == "init" ]; then
    /usr/local/bin/real-kubeadm init --ignore-preflight-errors=FileContent--proc-sys-net-bridge-bridge-nf-call-iptables --ignore-preflight-errors=FileExisting-crictl ${@:2}
else
    /usr/local/bin/real-kubeadm $@
fi
