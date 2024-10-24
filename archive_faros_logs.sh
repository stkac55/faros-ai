NAMESPACE=${NAMESPACE:-default}
TIMESTAMP=$(date +%Y%m%d%H%M%S)
LOGS_DIR="logs_${TIMESTAMP}"
LOGS_ARCHIVE_NAME="faros_logs_${TIMESTAMP}.tar.gz"

faros_charts="Chart.yaml"

mkdir -p $LOGS_DIR
# clean up logs dir
rm -rf ${LOGS_DIR:?}/*

echo "Collecting faros pod logs and writing to $LOGS_DIR"

# Iterate over the lines with service names
while read -r s_line ; do
    # get service name
    service=${s_line#*:}
    # trim spaces
    service=${service// /}
    # get pods for the given service
    while read -r p_line ; do
        # get pod name
        pod=${p_line#*/}
        # trim spaces
        pod=${pod// /}
        # get logs for the given pod
        kubectl logs -n $NAMESPACE $pod > ${LOGS_DIR}/${pod}.log
    done < <(kubectl get pods -o name --selector="app.kubernetes.io/name=$service")
done < <(grep '\- name:' "$faros_charts")

for e in pods services ingress; do
    echo "Collecting state of all $e and writing to $LOGS_DIR"
    kubectl get $e -n $NAMESPACE -o wide > ${LOGS_DIR}/${e}_state.log
done

# Archive all collected logs to a file with current timestamp
tar -czf "$LOGS_ARCHIVE_NAME" $LOGS_DIR/*
rm -rf $LOGS_DIR

echo "Logs are archived in $LOGS_ARCHIVE_NAME"
