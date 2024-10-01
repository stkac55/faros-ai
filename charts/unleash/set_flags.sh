#!/bin/bash

################################################################################
# Use this script to control feature flags for your on-prem faros.ai instance. #
# Reach out to the Faros team to find out which features are relevant to       #
# the behavior you are interested in. The Faros team will provide you with the #
# exact names of the feature flags you should be using.                        #
#                                                                              #
# Feature flags can be turned on, turned off or delete. If this is your        #
# first time using a feature flag the script will create it, otherwise this    #
# script will update it to on/off. It's also possible to delete feature        #
# flags. This should only be done if the feature flag is no longer in use.     #
#                                                                              #
# The URL will look like http(s)://baseurl.ai/unleash/api                      #
#                                                                              #
# To execute this script run the following                                     #
# ./set_flags.sh \                                                             #
#   -k <your unleash api key found in your aws password store> \               #
#   -u <the faros unleash url for your instance> \                             #
#   <feature-to-enable>=on \                                                   #
#   <second-feature-to-enable>=on \                                            #
#   <feature-to-disable>=off \                                                 #
#   <feature-no-longer-in-use>=delete                                          #
################################################################################


main() {
    parseInputs "$@"
    set -- "${PARAMS[@]:-}"
    processFeatureFlags "$@"

}

function processFeatureFlags() {
    testConnection
    while (($#)); do
        # Features are expected in for feature-flag-name=<on/off>
        IFS='='
        read -a parsedInput <<< "$1"
        featureName=${parsedInput[0] }
        featureEnabled=${parsedInput[1] }

        if [[ $featureEnabled == "delete" ]]; then
            deleteFlag "$featureName"
        elif [[ $featureEnabled == "on" ]] || [[ $featureEnabled == "off" ]]; then
            addOrUpdateFlag "$featureName" "$featureEnabled"
        else
            echo "Warning: Incorrectly formatted input. Arguments should be in form <feature-flag-name>=<on | off | delete> but instead was $1"
        fi
        shift 
    done
}

function testConnection() {
    status=$(curl -o /dev/null -s \
    -w "%{http_code}\n" \
    --request GET \
    -H "Authorization:$api_key" \
    --url "$unleash_url"/admin/features/)

    if [[ $status != "200" ]]; then 
        echo "Error: Unable to connect to Faros-Unleash. Check your url and api key."
        exit 1
    fi
}

function addOrUpdateFlag() {
    # 1=featureName 2=featureEnabled (on/off)
    # If flag exists update it, otherwise create it
    # https://docs.getunleash.io/reference/api/unleash

    status=$(curl -o /dev/null -s \
    -w "%{http_code}\n" \
    -X GET \
    -H "Authorization: $api_key" \
    --url "$unleash_url/admin/projects/default/features/$1" \
    )
    echo "Status for checking feature flag existence: '$status'."

    if [[ $status == "200" ]]; then 
        echo "Found feature $1 - updating."
        updateExistingFlag "$1" "$2"
    else 
        echo "Feature $1 not found - adding it."
        addFlag "$1" "$2"
    fi
}

function addFlag() {
    # 1=featureName 2=featureEnabled (on/off)
    createAddFlagPayload "$1" "$2"
    status=$(curl -o /dev/null -s \
        -w "%{http_code}\n" \
        -X POST \
        -H "Authorization: $api_key" \
        -H 'Content-Type: application/json' \
        --url "$unleash_url/admin/projects/default/features" \
        --data "$add_flag_payload")

    echo "Return status for adding flag: '$status'"
    if [[ $status == "201" ]]; then 
        echo "$1 feature flag created"
        updateExistingFlag "$1" "$2"

    else
        echo "Failed to create feature flag $1"
        #reviveFlagIfArchived "$1" "$2"
    fi
}

function updateExistingFlag() {
    # 1=featureName 2=featureEnabled (on/off)
    status=$(curl -o /dev/null -s \
        -w "%{http_code}\n" \
        -X POST \
        -H "Authorization: $api_key" \
        -H 'Content-Type: application/json' \
        --url $unleash_url"/admin/projects/default/features/"$1"/environments/default/"$2
        )
    echo "Status for update: '$status'"
    if [[ $status == "200" ]]; then 
        echo "Feature flag '$1' turned $2"
    else
        echo "Error: error in updating flag '$1'"
    fi
}

function deleteFlag() {
    status=$(curl -o /dev/null -s \
        -w "%{http_code}\n" \
        -X DELETE \
        -H "Authorization:$api_key" \
        --url "$unleash_url"/admin/features/"$1")

    if [[ $status == "200" ]]; then 
        echo "$1 feature flag delete"
    else
        echo "Error: error in deleting $1 flag"
    fi
}

function reviveFlagIfArchived() {
    archivedFlags=$(curl -s \
        -H "Authorization:$api_key" \
        --url "$unleash_url"/admin/archive/features)
    if [[ "$archivedFlags" != *"{\"name\":\"$1\","* ]]; then
        echo "Error: error in creating $1 feature flag"
    else # Create failed because flag was archived. Revive and update.
        status=$(curl -o /dev/null -s \
        -w "%{http_code}\n" \
        -X POST \
        -H "Authorization:$api_key" \
        -H 'Content-Type: application/json' \
        --url "$unleash_url"/admin/archive/revive/"$1")
        if [[ $status == "200" ]]; then 
            echo "$1 feature flag revived (was archived)"
            updateExistingFlag "$1" "$2"
        else
            echo "Error: $1 feature flag is archived and reviving failed"
        fi
    fi
}

function parseInputs() {
    while (($#)); do 
        case "$1" in 
            -k|--api_key)
                api_key="$2"
                shift 2 ;;
            -u|--unleash_url)
                unleash_url="$2"
                shift 2 ;;
            -*|--*=)
                echo "Error: Unsupported flag $1" >&2
                exit 1
                ;;
            *) # preserve positional arguments
                PARAMS+=("$1")
                shift
                ;;
        esac
    done

    if [[ -z "$api_key" ]]; then 
        echo "API Key must be set"
        exit 1
    fi

    if [[ -z "$unleash_url" ]]; then
        echo "Unleash URL must be set"
        exit 1
    fi

    if [[ "$unleash_url" != */api ]]; then
        echo "Unleash URL must end with /api"
        exit 1
    fi
}

function createAddFlagPayload() {
    add_flag_payload="{
      \"type\": \"release\",
      \"name\": \"$1\",
      \"description\": \"\",
      \"impressionData\": false
    }"
}


main "$@"; exit
