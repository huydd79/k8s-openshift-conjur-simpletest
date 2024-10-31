#/bin/sh
source 00.config.sh

if [[ "$READY" != true ]]; then
    echo "Your configuration are not ready. Set READY=true in 00.config.sh when you are done"
    exit
fi

# Loading conjur policy for jwt authentication
echo "Configuring conjur-test hostid... "
conjur policy load -b root -f jwt-host-conjur-test.yaml
[[ $? -eq 0 ]] && echo "Done!!!"  || echo "ERROR!!!"

