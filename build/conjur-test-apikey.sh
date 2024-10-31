#!/bin/sh

if [[ -z "${CONJUR_HOST}" ]]; then
    echo "INVALID ENVIRONMENT PARAMETER. PLEAS SET CORRECT VALUE FOR CONJUR_HOST"
    exit
fi
if [[ -z "${CONJUR_PORT}" ]]; then
    echo "INVALID ENVIRONMENT PARAMETER. PLEAS SET CORRECT VALUE FOR CONJUR_PORT"
    exit
fi
if [[ -z "${CONJUR_ACCOUNT}" ]]; then
    echo "INVALID ENVIRONMENT PARAMETER. PLEAS SET CORRECT VALUE FOR CONJUR_ACCOUNT"
    exit
fi
if [[ -z "${CONJUR_USER}" ]]; then
    echo "INVALID ENVIRONMENT PARAMETER. PLEAS SET CORRECT VALUE FOR CONJUR_USER"
    exit
fi
if [[ -z "${CONJUR_KEY}" ]]; then
    echo "INVALID ENVIRONMENT PARAMETER. PLEAS SET CORRECT VALUE FOR CONJUR_KEY"
    exit
fi
if [[ -z "${CONJUR_SECRET_PATH}" ]]; then
    echo "INVALID ENVIRONMENT PARAMETER. PLEAS SET CORRECT VALUE FOR CONJUR_SECRET_PATH"
    exit
fi

CONJUR_URL="https://$CONJUR_HOST:$CONJUR_PORT"

set -x
AUTH_TOKEN=$(curl -k --request POST $CONJUR_URL/authn/$CONJUR_ACCOUNT/$CONJUR_USER/authenticate \
                  --data-raw "$CONJUR_KEY"|base64 -w 0)
echo
set +x
if [[ -z "${AUTH_TOKEN}" ]]; then
    echo "AUTHENTICATION FAILED. PLEASE CHECK DEBUG INFO, LOG DATA AND ADJUST YOUR CONFIGURATION"
    exit
fi
set -x
SECRET=$(curl -k --request GET $CONJUR_URL/secrets/$CONJUR_ACCOUNT/variable/$CONJUR_SECRET_PATH \
                --header "Authorization: Token token=\"$AUTH_TOKEN\"")
echo
set +x
sleep 1

echo "=================================="
echo "Result from conjur: SECRET=$SECRET"
echo "=================================="

