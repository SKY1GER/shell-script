#!/bin/bash
set -e

echo "🔍 Finding all PVCs in the cluster..."
PVC_LIST=$(kubectl get pvc --all-namespaces --no-headers -o custom-columns=":metadata.namespace,:metadata.name")

if [ -z "$PVC_LIST" ]; then
    echo "✅ No PVCs found in the cluster."
    exit 0
fi

while read -r line; do
    NAMESPACE=$(echo $line | awk '{print $1}')
    PVC_NAME=$(echo $line | awk '{print $2}')

    echo -e "\n=============================="
    echo "📦 Namespace: $NAMESPACE | PVC: $PVC_NAME"
    echo "=============================="

    # Get PV bound to this PVC
    PV_NAME=$(kubectl get pvc $PVC_NAME -n $NAMESPACE -o jsonpath='{.spec.volumeName}' 2>/dev/null || true)

    # Find Pods using this PVC
    PODS=$(kubectl get pod -n $NAMESPACE --no-headers \
        -o custom-columns=":metadata.name" \
        --field-selector spec.volumes.persistentVolumeClaim.claimName=$PVC_NAME 2>/dev/null || true)

    if [ -n "$PODS" ]; then
        for POD in $PODS; do
            echo "🗑 Deleting Pod: $POD"
            kubectl delete pod $POD -n $NAMESPACE --grace-period=0 --force
        done
    else
        echo "⚠ No Pods found for PVC: $PVC_NAME"
    fi

    # Find Services (by label match)
    SVC=$(kubectl get svc -n $NAMESPACE --no-headers \
        -o custom-columns=":metadata.name" \
        --selector="app=$PVC_NAME" 2>/dev/null || true)
    if [ -n "$SVC" ]; then
        for S in $SVC; do
            echo "🗑 Deleting Service: $S"
            kubectl delete svc $S -n $NAMESPACE --grace-period=0 --force
        done
    else
        echo "⚠ No Services found for PVC: $PVC_NAME"
    fi

    # Delete PVC
    echo "🗑 Deleting PVC: $PVC_NAME"
    kubectl delete pvc $PVC_NAME -n $NAMESPACE --grace-period=0 --force || true

    # Delete PV if exists
    if [ -n "$PV_NAME" ]; then
        echo "🔓 Removing PV finalizers for: $PV_NAME"
        kubectl patch pv $PV_NAME -p '{"metadata":{"finalizers":null}}' --type=merge || true

        echo "🗑 Deleting PV: $PV_NAME"
        kubectl delete pv $PV_NAME --grace-period=0 --force || true
    else
        echo "⚠ No PV found for PVC: $PVC_NAME"
    fi

done <<< "$PVC_LIST"

echo -e "\n✅ All PVCs, PVs, Pods, and Services have been force deleted."
