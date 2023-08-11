#!/usr/bin/env bash

#################################
# include the -=magic=-
# you can pass command line args
#
# example:
# to disable simulated typing
# . ../demo-magic.sh -d
#
# pass -h to see all options
#################################
. $HOME/bin/demo-magic.sh

. ./tools/setup-onprem-k8s-env.sh

########################
# Configure the options
########################

#
# speed at which to simulate typing. bigger num = faster
#
# TYPE_SPEED=20

#
# custom prompt
#
# see http://www.tldp.org/HOWTO/Bash-Prompt-HOWTO/bash-prompt-escape-sequences.html for escape sequences
#
#DEMO_PROMPT="${GREEN}➜ ${CYAN}\W ${COLOR_RESET}"
# Display git branch in prompt
DEMO_PROMPT=$PS1


# text color
# DEMO_CMD_COLOR=$BLACK

# hide the evidence
clear

# enters interactive mode and allows newly typed command to be executed
cmd

# Show the local processes
pe "watch podman ps"

#Deploy the frontend
pe "oc apply -f ./yaml/frontend-dep.yaml"

pe "watch oc get pods,svc"

pe "skupper init --site-name on-prem --enable-console --enable-flow-collector --console-auth=internal --console-user=admin --console-password=password"

pe "watch oc get svc,pods"

pe "skupper gateway expose backend 127.0.0.1 8080 --type podman"

pe "watch podman ps"

pe "oc get svc,pods"

pe "skupper gateway status"

pe "skupper network status"

pe "oc get svc/backend -o yaml"

# Decommission the on-premises frontend
pe "podman kill frontend"

echo "*** Move to Sydney ***"

# Migrate the frontend to the public cloud
pe "skupper link create sydney-token.yaml"

pe "skupper network status"

pe "oc delete -f yaml/frontend.yaml"

# Now let's move the backend
pe

pe "skupper gateway expose db 127.0.0.1 5432 --type podman"

pe "oc apply -f ./yaml/backend-dep.yaml"

pe "watch oc get pods,svc"

# TODO: Display the logs of the backend pod to make sure it is connecting
pe

pe "skupper gateway unexpose backend"

pe "skupper gateway status"
pe

pe "skupper expose deployment backend --port 8080"

pe "skupper network status"