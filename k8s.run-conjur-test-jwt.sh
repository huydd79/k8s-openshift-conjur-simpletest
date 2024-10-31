#/bin/sh
source 00.config.sh

if [[ "$READY" != true ]]; then
    echo "Your configuration are not ready. Set READY=true in 00.config.sh when you are done"
    exit
fi

APP_NAME="conjur-test-jwt"
YML_FILE="yaml/$APP_NAME.yaml"
YML_TEMP="/tmp/$APP_NAME.yaml"
K8S_NS="cyberark-poc"

set -x
kubectl get namespace | grep -q cyberark-poc || kubectl create namespace cyberark-poc
kubectl -n cyberark-poc get deployments | grep -q $APP_NAME
if [ $? -eq 0 ]; then
    kubectl -n cyberark-poc delete deployment $APP_NAME
    ret=0
    until [ $ret -ne 0 ]
    do
        kubectl -n cyberark-poc get deployments | grep -q $APP_NAME
        ret=$?
        echo "Waiting deployment is deleted..."
        sleep 1
    done

fi

#cp $YML_FILE $YML_TEMP
#sed -i "s/{LAB_IP}/$LAB_IP/g" $YML_TEMP
#sed -i "s/{LAB_DOMAIN}/$LAB_DOMAIN/g" $YML_TEMP


kubectl -n cyberark-poc apply -f $YML_FILE

#rm $YML_TEMP
set +x