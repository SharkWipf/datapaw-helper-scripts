#!/bin/bash

# Usage:
# Export a Datapaw-formatted Google Sheet for the masternode file you want to generate
# Make this script executable by running `chmod +x ./masternodeparser_csv.sh` (only need to do this once)
# Then run: ./masternodeparser_csv.sh /path/to/file.csv

file="$1"
rxaddress="$2"
sharesize="$3"

epath="$(dirname "$0")"

. "$epath/lib/common.sh"

while read line; do
    username_new="$(echo "$line" | awk -F ',' '{print $1}' | sed -e 's/^ *//;s/ *$//')"
    txid_new="$(    echo "$line" | awk -F ',' '{print $5}' | sed -e 's/^ *//;s/ *$//')"
    address_new="$( echo "$line" | awk -F ',' '{print $14}' | sed -e 's/^ *//;s/ *$//')"
    amount_new="$(  echo "$line" | awk -F ',' '{print $23}' | sed -e 's/^ *//;s/ *$//')"

    echo "$line" | grep -e '^[,]\+$' &>/dev/null
    if [[ $? -eq 0 ]]; then
        generatePayees - -
        break
    fi
    generatePayees "$username_new" "$txid_new" "$address_new" "$amount_new"

done <<< "$(tail -n +2 "$file" | dos2unix)"

echo
echo "// Total shares counted: $totalshares"

if varNotEmpty "$totalpaid" "$sharesize"; then
    echo "// Total Shares paid: $(($totalpaid / $sharesize)) ($totalpaid coins)"
fi
