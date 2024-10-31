# k8s-openshift-conjur-simpletest
Container image, policies, deployment configure and other configuration for testing conjur in K8s or OCP env

huy.do@cyberark.com

If you are on the POC or building the lab environment and want to test out the conjur integrtion with an container app running on K8s or OCP environment, the information and resource from this repo will help you to quickly deploy sample container and checking for conjur configuration.

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
In above example, the test script will use testuser01@test as userid when sending authentication request to conjur

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

### Deploy simpletest container
