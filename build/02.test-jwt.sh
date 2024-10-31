name=conjur-test
CONTAINER_MGR="podman"

$CONTAINER_MGR ps -a | grep $name >/dev/null 2>&1
if [ $? -eq 1 ]; then
    echo "Container $name is not existed. Creating new one..."
else
    echo "Container $name existed. Deleting old one..."
    $CONTAINER_MGR stop $name
    $CONTAINER_MGR container rm $($CONTAINER_MGR ps -a | grep $name | awk '{print $1}')
fi

set -x

$CONTAINER_MGR run --name $name --detach \
    -v $PWD/test-jwt:/var/run/secrets/tokens/jwt \
    -e TEST_MODE="JWT" \
    -e CONJUR_HOST="172.16.100.15" \
    -e CONJUR_PORT="443" \
    -e CONJUR_ACCOUNT="DEMO" \
    -e CONJUR_SECRET_PATH="test/host1/pass" \
    -e CONJUR_JWT_SERVICE_NAME=k8s \
    -e CONJUR_JWT_PATH=/var/run/secrets/tokens/jwt \
    conjur-simpletest

$CONTAINER_MGR logs -f $name

set +x