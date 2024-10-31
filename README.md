# k8s-openshift-conjur-simpletest
Container image, policies, deployment configure and other configuration for testing conjur in K8s or OCP env

huy.do@cyberark.com

If you are on the POC or building the lab environment and want to test out the conjur integrtion with an container app running on K8s or OCP environment, the information and resource from this repo will help you to quickly deploy sample container and checking for conjur configuration.

Incase you want to learn about this integration but doesn't have K8s or OCP environment yet, please follow below links to quickly build your own:
K8s: https://github.com/huydd79/conjur-k8s-lab
OCP: https://github.com/huydd79/conjur-ocp.local-lab

## Deployment and testing steps:
### Building the container image
Container image for this testing has been built and available at docker hub with name: doduchuy/conjur-simpletest. However, if you want to build or customize your own image, you can use scripts in build folder to build, test and pack your image for later usage.

### Testing the container image
Container conjur-simpletest image requires few environment parameters to be run. Detail of parameters are as below:
- TEST_MODE: select test mode for container to run. At current version, there are two mode are supported
  - APIKEY: testing conjur authentication using UserID and API Key
  - JWT: testing conjur authentication using JWT
- CONJUR_HOST: IP address, hostname or FQND of conjur appliance (follower or leader that you want to test)
- CONJUR_PORT: HTTPS port that conjur service is listening for communication
- CONJUR_ACCOUNT: conjur account name when deploy conjur
- CONJUR_SECRET_PATH: the secret path in conjur that you want to retrieve for testing purpose

Depend on TEST_MODE, there are some more environment parameters will be required:
- CONJUR_USER: this is required when running APIKEY mode, for userID that is used for authentication
- CONJUR_KEY: this is required when running APIKEY mode, for API Key that is used for authentication
- CONJUR_JWT_SERVICE_NAME: this is required when running JWT mode, it is pointed to jwt authentication service name that conjur using. For example if the authentication service is authn-jwt/k8s then the service name is k8s
- CONJUR_JWT_PATH: this is required when running JWT mode. This path is locating for jwt file for authentication purpose
   
For example, command to run image in APIKEY mode for testing with docker
```
docker run --name $name --detach \
    -e TEST_MODE="APIKEY" \
    -e CONJUR_HOST="172.16.100.15" \
    -e CONJUR_PORT="443" \
    -e CONJUR_ACCOUNT="DEMO" \
    -e CONJUR_USER=testuser01@test \
    -e CONJUR_KEY="2h2mscd1pc2b3j27aa3q0hbhavp2ffgs4836ypss23vqy0br3ffqdw4" \
    -e CONJUR_SECRET_PATH="test/host1/pass" \
    conjur-simpletest
```
In above example, the test script will use testuser01@test as userid when sending authentication request to conjur. To get the correct hostid and api key in your conjur environment, login using conjur cli as admin user and running below command:
```
conjur user rotate-api-key -i testuser01@test
```
Replace testuser01@test by your actuall userid and copy the api key for testing.

Example of docker command to run image in JWT mode
```
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
```
Please note that in above example, we are using test-jwt file for testing. This file contain the sample jwt value and will not be accepted by your conjur system. You need to configure your conjur to add correct hostid, policy to allow jwt token generated from your K8s or Openshift env and extract jwt value from that environment for testing.

### Configuring conjur environment
This steps is required when you want to test JWT authentication. This configuration is similar when doing testing on K8s and OCP.
All scrips for conjur policy configuration are put in policies folder. Please run those script in machine with conjur cli logged in as admin.

#### Enabling JWT authenticaiton for K8s
This step creates some new variables in conjur environment to store the jwt configuration including
- public-keys: JWT provider's public key (this will be imported from K8s or OCP public key)
- issuer: the issuer configured in JWT payload
- token-app-property: the attribute in JWT payload that contains the hostid for authentication
- identity-path: additional attribute to link to hostid created in conjur
- audience: the audience value in JWT payload
#### Configuring hostid for conjur-simpletest container
This step runs the policy config to add a new hostid to conjur environment and grant permission so that this host can do authentication and request the credential. HostID uses in this testing is created bases on combination of namespace and service account
- namespace: cyberark-poc
- service account: conjur-test
- identity-path: jwt-apps/k8s
- hostid: jwt-apps/k8s/system:serviceaccount:cyberark-poc:conjur-test
#### Loading JWT provider's information to conjur JWT configuration
This step loads the information from your K8s or OCP environment to conjur variables for authentication purpose. There are two value that need to be extract from K8s or OCP: PUBLIC_KEYS and ISSUER

Getting information using kubectl in K8s env:
```
PUBLIC_KEYS="$(kubectl get --raw $(kubectl get --raw /.well-known/openid-configuration | jq -r '.jwks_uri'))"
ISSUER="$(kubectl get --raw /.well-known/openid-configuration | jq -r '.issuer')"
```

Getting information using oc in OCP env:
```
PUBLIC_KEYS="$(oc get --raw $(oc get --raw /.well-known/openid-configuration | jq -r '.jwks_uri'))"
ISSUER="$(oc get --raw /.well-known/openid-configuration | jq -r '.issuer')"
```

NOTE: If you are conjur admin and don't have access to K8s or OCP environment, you need to get this information for K8s or OCP admin.

After got above info, running conjur cli commands to add configuration into conjur
```
conjur variable set -i conjur/authn-jwt/k8s/public-keys -v "{\"type\":\"jwks\", \"value\":$PUBLIC_KEYS}"
conjur variable set -i conjur/authn-jwt/k8s/issuer -v $ISSUER
conjur variable set -i conjur/authn-jwt/k8s/token-app-property -v sub
conjur variable set -i conjur/authn-jwt/k8s/identity-path -v jwt-apps/k8s
conjur variable set -i conjur/authn-jwt/k8s/audience -v cybrdemo
```
### Deploy simpletest container
Default configuration in this repo is using cyberark-poc as namespace and conjur-test as service account. So if you don't do any changes, you need to create the correct namespace for it to run.
Command in K8s
```
kubectl get namespace | grep -q cyberark-poc || kubectl create namespace cyberark-poc
```
Command in OCP
```
oc get namespace | grep -q $K8S_NS || oc create namespace cyberark-poc
```

Please review deployment config files in yaml folder and deploy to your env for testing purpose. You need to change all environment variable in these file to apply to your actual environment.

### Debug and troubleshooting
Testing script provides result in log, you can review container logs for detail result.

For more troubleshooting, you can enter the container environment and run the script directly. All script are put at / folder in container environment

## END





