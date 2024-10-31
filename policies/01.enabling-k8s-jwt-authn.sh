#/bin/sh
source 00.config.sh

if [[ "$READY" != true ]]; then
    echo "Your configuration are not ready. Set READY=true in 00.config.sh when you are done"
    exit
fi
CONJUR_URL="https://$CONJUR_HOST:$CONJUR_PORT"

# Loading conjur policy for jwt authentication
echo "Configuring authn-jwt/k8s authenticator... "
conjur policy load -b root -f jwt-auth-k8s.yaml
[[ $? -eq 0 ]] && echo "Done!!!"  || echo "ERROR!!!"

# Generating /etc/conjur/config/conjur.yaml file
echo "Generating conjur configuration for authenticators options... "
set -x

CONF_FILE=/etc/conjur/config/conjur.yml
TEMP_FILE=/tmp/conjur.yml
$SUDO $CONTAINER_MGR cp conjur:$CONF_FILE $TEMP_FILE
[ -f "$TEMP_FILE" ] && $SUDO $CONTAINER_MGR exec conjur mv $CONF_FILE $CONF_FILE.bk.$(date +%s)
#Enabling all configured authn methods
auth_json=$(curl -sk $CONJUR_URL/info | jq '.authenticators.configured')
cat << EOF > $TEMP_FILE
#This file is created by script $0"
authenticators: $auth_json
EOF
$SUDO $CONTAINER_MGR cp $TEMP_FILE conjur:$CONF_FILE

echo "Activating authenticator..."
$SUDO $CONTAINER_MGR exec conjur evoke configuration apply
[[ $? -eq 0 ]] && echo "Done!!!"  || echo "ERROR!!!"