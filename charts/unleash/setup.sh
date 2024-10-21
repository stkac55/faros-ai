#!/bin/bash

set -u

# Environment variables that can be set at runtime to change default values:
# FAROS_NAME_SPACE            - Kubernetes namespace of the Faros deployment
# FAROS_HELM_DEPLOYMENT_NAME  - Name of Faros Helm deployment. Defaults to faros-ai
# UNLEASH_PORT                - Port of the unleash container, defaults to 4242

FAROS_NAME_SPACE=${FAROS_NAME_SPACE:-"default"}
FAROS_HELM_DEPLOYMENT_NAME=${FAROS_HELM_DEPLOYMENT_NAME:-"faros-ai"}
UNLEASH_SERVICE_NAME="$FAROS_HELM_DEPLOYMENT_NAME-unleash"
ALASTOR_SERVICE_NAME="$FAROS_HELM_DEPLOYMENT_NAME-alastor"
UNLEASH_PORT=${UNLEASH_PORT:-"4242"}
UNLEASH_URL="http://localhost:${UNLEASH_PORT}/unleash"

UNLEASH_ADMIN_DEFAULT_USERNAME="admin"
UNLEASH_ADMIN_DEFAULT_PASSWORD=unleash4all
UNLEASH_ADMIN_API="$UNLEASH_URL/api/admin"
WAIT_FOR_UNLEASH_SLEEP_TIME=10

# Fetch desired unleash admin password set during helm install
UNLEASH_ADMIN_PASSWORD=$(kubectl get secret $UNLEASH_SERVICE_NAME -o jsonpath='{.data.UNLEASH_ADMIN_PASSWORD}' -n $FAROS_NAME_SPACE | base64 --decode)
# Fetch UNLEASH_APP_NAME from alastor's config map set at deployment
UNLEASH_APP_NAME=$(kubectl get configmaps $ALASTOR_SERVICE_NAME -o jsonpath='{.data.NEXT_PUBLIC_UNLEASH_APP_NAME}' -n $FAROS_NAME_SPACE)

function checkUtils() {
  declare -a arr=("curl" "jq" "sed" "grep" "tr" "kubectl")
  missing_require=0
  for i in "${arr[@]}"; do
      which "$i" &> /dev/null ||
          { echo "Error: $i is required." && missing_require=1; }
  done
  if ((missing_require)); then
    exit 1
  fi
}

function waitForUnleashAvailable() {
  UnleashReady=0

  for I in 1 2 3 4 5 6 7 8 9 10 11 12; do
    curl -sSL "$UNLEASH_URL/health" -o /dev/null
    if [ $? = 0 ]; then
      UnleashReady=1
      break
    fi
    echo "Cannot connect to Unleash API. Trying again in a moment."
    sleep $WAIT_FOR_UNLEASH_SLEEP_TIME
  done

  if [ $UnleashReady = 0 ]; then
    echo "Cannot connect to Unleash API, avoiding further configuration."
    exit 1
  fi
}

# Login with default admin and retrieve session token
function loginWithDefaultAdmin() {
  echo "Logging in with default admin..."
  http_response=$(curl -sSL --write-out "HTTPSTATUS:%{http_code}" -D - "$UNLEASH_URL/auth/simple/login" -o /dev/null \
    -H 'Content-Type: application/json' \
    -H 'Accept: application/json' \
    -d "{ \"username\": \"$UNLEASH_ADMIN_DEFAULT_USERNAME\", \"password\": \"$UNLEASH_ADMIN_DEFAULT_PASSWORD\" }")

  http_response_status=$(echo $http_response | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')

  # Check to see if Unleash has already been provisioned (default admin's creds updated already)
  if [[ $http_response_status == "401" ]]; then
    echo "Could not log in with default admin. Unleash was already configured."
    exit 0
  fi

  session_token=$(echo "$http_response" | grep -Fi Cookie | sed 's/.*unleash-session=\(.*\); Path.*/\1/')
  cookie="unleash-session=$session_token"
}

# Create, retrieve and export API token from Unleash
function configureApiToken() {
  echo "Retrieving api token..."
  http_response=$(curl -sSL --write-out "HTTPSTATUS:%{http_code}" "$UNLEASH_ADMIN_API/api-tokens" \
    -H "Cookie: $cookie" \
    -H 'Content-Type: application/json' \
    -H 'Accept: application/json' \
    -d '{ "username": "faros-service-key", "type": "ADMIN"}')

  http_response_status=$(echo $http_response | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')
  http_response_body=$(echo $http_response | sed -e 's/HTTPSTATUS\:.*//g')
  api_token=$(echo "$http_response_body" | jq -r '.secret')
  if [ $http_response_status == "201" ]; then
    if ! [ -z ${api_token+x} ] && ! [ $api_token == "null" ]; then
      echo "Obtained API token..."
    else
      echo "Unleash API token was unset when attempting to export"
      exit 1
    fi
  else
    echo "Error retrieving Unleash API was: $http_response_status"
    exit 1
  fi
}

# Create metrics application with provided name (required for unleash-proxy)
function createMetricsApp() {
  echo "Creating metics app..."
  curl -sSL -X POST "$UNLEASH_ADMIN_API/metrics/applications/$UNLEASH_APP_NAME" \
    -H "Cookie: $cookie" \
    -H 'Content-Type: application/json' \
    -H 'Accept: application/json' \
    -d "{\"appName\": \"$UNLEASH_APP_NAME\"}"
}

# Enable default environment - The default environment may be deprecated in the future
function enableDefaultEnvironment() {
  echo "Enabling default environment..."
  curl -sSL -X POST "$UNLEASH_ADMIN_API/projects/default/environments" \
    -H "Cookie: $cookie" \
    -H 'Content-Type: application/json' \
    -H 'Accept: application/json' \
    -d "{\"environment\": \"default\"}"
}

# Disable development environment
function disableDevelopmentEnvironment() {
  echo "Disabling development environment..."
  curl -sSL -X DELETE "$UNLEASH_ADMIN_API/projects/default/environments/development" \
    -H "Cookie: $cookie" \
    -H 'Content-Type: application/json' \
    -H 'Accept: application/json'
}

# Disable production environment
function disableProductionEnvironment() {
  echo "Disabling production environment..."
  curl -sSL -X DELETE "$UNLEASH_ADMIN_API/projects/default/environments/production" \
    -H "Cookie: $cookie" \
    -H 'Content-Type: application/json' \
    -H 'Accept: application/json'
}

# Update default admins password to provided new password
function updateAdminPassword() {
  echo "Updating default admin's password..."
  curl -sSL -X POST "${UNLEASH_ADMIN_API}/user/change-password" \
    -H "Cookie: $cookie" \
    -H 'Content-Type: application/json' \
    -d "{\"password\": \"$UNLEASH_ADMIN_PASSWORD\", \"confirmPassword\": \"$UNLEASH_ADMIN_PASSWORD\"}"
}


echo "$UNLEASH_SERVICE_NAME -- $UNLEASH_PORT $UNLEASH_ADMIN_PASSWORD"
kubectl port-forward service/$UNLEASH_SERVICE_NAME $UNLEASH_PORT:$UNLEASH_PORT -n $FAROS_NAME_SPACE &

checkUtils
waitForUnleashAvailable
loginWithDefaultAdmin
configureApiToken
createMetricsApp
enableDefaultEnvironment
disableDevelopmentEnvironment
disableProductionEnvironment
updateAdminPassword

# Terminate port forwarding to unleash container
pkill -9 kubectl
# Secret name is the same as unleash app name
kubectl patch secret $UNLEASH_SERVICE_NAME -p="{\"stringData\":{\"UNLEASH_API_TOKEN\": \"$api_token\"}}" -v=1 -n $FAROS_NAME_SPACE
echo "Unleash API token in secrets $UNLEASH_SERVICE_NAME was updated"
echo 'Run "'"export UNLEASH_API_TOKEN=$api_token"'" to set the token in your environment'

# Restart Alastor after updating UNLEASH_API_TOKEN secret
kubectl rollout restart deployment $ALASTOR_SERVICE_NAME -n $FAROS_NAME_SPACE

echo "Unleash configured and its API token value is set in k8s secrets"


