#/bin/sh
source 00.config.sh

if [[ "$READY" != true ]]; then
    echo "Your configuration are not ready. Set READY=true in 00.config.sh when you are done"
    exit
fi

APP_NAME="conjur-test-apikey"
YML_FILE="yaml/$APP_NAME.yaml"
K8S_NS="cyberark-poc"

eval $(crc oc-env)

set -x
oc get namespace | grep -q $K8S_NS || oc create namespace $K8S_NS
oc -n $K8S_NS get deployments | grep -q $APP_NAME
if [ $? -eq 0 ]; then
    oc -n $K8S_NS delete deployment $APP_NAME
    ret=0
    until [ $ret -ne 0 ]
    do
        oc -n $K8S_NS get deployments | grep -q $APP_NAME
        ret=$?
        echo "Waiting deployment is deleted..."
        sleep 1
    done

fi

oc -n $K8S_NS apply -f $YML_FILE

set +x