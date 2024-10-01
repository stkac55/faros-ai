declare -a features=("create-v2-graphs" "catalog-version-2" "disable-v1-graph-creation")

echo $UNLEASH_URL
# Read the array values with space
for val in "${features[@]}"; do
 ./set_flags.sh -k $UNLEASH_API_TOKEN -u "$UNLEASH_URL/api" "$val=on"
done

