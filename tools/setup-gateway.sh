#! /bin/bash

skupper init --site-name on-prem --console-auth=internal --console-user=admin --console-password=password

skupper gateway expose backend 127.0.0.1 8080 --type podman


