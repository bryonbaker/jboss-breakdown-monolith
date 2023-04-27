#! /bin/bash

rm -rf ~/.local/share/skupper

podman kill --all 

podman system prune --force

