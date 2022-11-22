#! /bin/bash

echo "Setting up isolated Kubernetes environment"
echo "NOTE: The command format to run this script is: \". ./setup-onprem-k8s-env.sh\""

export KUBECONFIG=$HOME/.kube/app-modernisation-onprem
export PS1="\[$(tput setaf 2)\]ONPREM: \[$(tput setaf 7)\]\[$(tput setaf 6)\]\W\\$ \[$(tput setaf 7)\]\[$(tput sgr0)\]"
