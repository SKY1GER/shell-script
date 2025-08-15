# 7. S3 Buckets & Sizes (without jq/bc)
echo
echo "[7] S3 Buckets & Sizes (may take time to list):"
for bucket in $(aws s3api list-buckets --query "Buckets[].Name" --output text); do
    size_bytes=$(aws s3api list-objects --bucket "$bucket" --output json --query "sum(Contents[].Size)" 2>/dev/null)
    if [ "$size_bytes" == "null" ] || [ -z "$size_bytes" ]; then
        size_bytes=0
    fi
    size_gb=$(awk "BEGIN {printf \"%.2f\", $size_bytes/1024/1024/1024}")
    echo " - $bucket: ${size_gb} GB"
done
