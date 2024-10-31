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
if [[ -z "${CONJUR_SECRET_PATH}" ]]; then
    echo "INVALID ENVIRONMENT PARAMETER. PLEAS SET CORRECT VALUE FOR CONJUR_SECRET_PATH"
    exit
fi
if [[ -z "${CONJUR_JWT_SERVICE_NAME}" ]]; then
    echo "INVALID ENVIRONMENT PARAMETER. PLEAS SET CORRECT VALUE FOR CONJUR_JWT_SERVICE_NAME"
    exit
fi
if [[ -z "${CONJUR_JWT_PATH}" ]]; then
    echo "INVALID ENVIRONMENT PARAMETER. PLEAS SET CORRECT VALUE FOR CONJUR_JWT_PATH"
    exit
fi
if [[ ! -f ${CONJUR_JWT_PATH} ]]; then
    echo "JWT FILE $CONJUR_JWT_PATH IS NOT EXISTED. PLEASE CHECK YOUR ENVIRONMENT"
    exit
fi

CONJUR_URL="https://$CONJUR_HOST:$CONJUR_PORT"

set -x
JWT=$(cat $CONJUR_JWT_PATH | tr -d '\r')
echo
AUTH_TOKEN=$(curl -k -X POST $CONJUR_URL/authn-jwt/$CONJUR_JWT_SERVICE_NAME/$CONJUR_ACCOUNT/authenticate \
                --data-raw "jwt=$JWT" | base64 -w 0)
set +x
if [[ -z "${AUTH_TOKEN}" ]]; then
    echo "AUTHENTICATION FAILED. PLEASE CHECK DEBUG INFO, LOG DATA AND ADJUST YOUR CONFIGURATION"
    exit
fi
set -x
echo
SECRET=$(curl -k --request GET $CONJUR_URL/secrets/$CONJUR_ACCOUNT/variable/$CONJUR_SECRET_PATH \
                --header "Authorization: Token token=\"$AUTH_TOKEN\"")
echo
set +x
sleep 1

echo "=================================="
echo "Result from conjur: SECRET=$SECRET"
echo "=================================="

