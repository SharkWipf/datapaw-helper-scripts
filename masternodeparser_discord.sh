#!/bin/bash

# Usage:
# Copy a Datapaw masternode Discord server log, just, drag and drop the entire channel log.
# Throw said log into a file, just paste the whole thing in your favorite text editor (vim of course) and save it.
# Make this script executable by running `chmod +x ./masternodeparser_discord.sh` (only need to do this once)
# Then run: ./masternodeparser_discord.sh /path/to/discord/log.txt

file="$1"
rxaddress="$2"
sharesize="$3"

epath="$(dirname "$0")"

. "$epath/lib/common.sh"

while read line; do
    username_new="$(echo "$line" | awk -F '[|/]' '{print $1}' | sed -e 's/^ *//;s/ *$//')"
    txid_new="$(    echo "$line" | awk -F '[|/]' '{print $2}' | sed -e 's/^ *//;s/ *$//')"
    address_new="$( echo "$line" | awk -F '[|/]' '{print $3}' | sed -e 's/^ *//;s/ *$//')"
    amount_new="$(  echo "$line" | awk -F '[|/]' '{print $4}' | sed -e 's/^ *//;s/ *$//;s/^\([0-9]*\).*$/\1/')"

    generatePayees "$username_new" "$txid_new" "$address_new" "$amount_new"

done <<< "$(grep "$file" -e '^.*#.*|.*|.*|.*$' -e '^.*#.*/.*/.*/.*$' | grep -oe '^.*[0-9]' | sort)"

generatePayees - -

echo

echo "// Total Shares counted: $totalshares"

if varNotEmpty "$totalpaid" "$sharesize"; then
    echo "// Total Shares paid: $(($totalpaid / $sharesize)) ($totalpaid coins)"
fi

