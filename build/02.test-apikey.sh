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
    -e TEST_MODE="APIKEY" \
    -e CONJUR_HOST="172.16.100.15" \
    -e CONJUR_PORT="443" \
    -e CONJUR_ACCOUNT="DEMO" \
    -e CONJUR_USER=testuser01@test \
    -e CONJUR_KEY="2h2mscd1pc2b3j27aa3q0hbhavp2ffgs4836ypss23vqy0br3ffqdw4" \
    -e CONJUR_SECRET_PATH="test/host1/pass" \
    conjur-simpletest

$CONTAINER_MGR logs -f $name

set +x