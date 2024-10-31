#!/bin/sh

while true; do
    echo "======================================"
    echo "$(date) - start test script..."
    case "$TEST_MODE" in
        JWT) /conjur-test-jwt.sh;;
        APIKEY) /conjur-test-apikey.sh;;
        *) echo "Please set TEST_MODE in environment variable and run again!";;
    esac
    echo "$(date) - test script end!"
    echo "======================================"
    sleep 300
done


