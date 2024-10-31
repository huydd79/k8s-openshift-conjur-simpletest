#!/bin/bash

CONTAINER_MGR="podman"
$CONTAINER_MGR build -t conjur-simpletest .
