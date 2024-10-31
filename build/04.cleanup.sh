#!/bin/sh
podman rmi $(podman images -a | grep conjur-simpletest | awk '{print $3}')
podman rmi $(podman images --filter "dangling=true" -q --no-trunc)