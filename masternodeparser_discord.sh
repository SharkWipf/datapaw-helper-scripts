#!/bin/bash

# Usage:
# Copy a Datapaw masternode Discord server log, just, drag and drop the entire channel log.
# Throw said log into a file, just paste the whole thing in your favorite text editor (vim of course) and save it.
# Make this script executable by running `chmod +x ./masternodeparser_discord.sh` (only need to do this once)
# Then run: ./masternodeparser_discord.sh /path/to/discord/log.txt

totalshares=0
file="$1"
first=true

while read line; do
    username_new="$(echo "$line" | awk -F '[|/]' '{print $1}' | sed -e 's/^ *//;s/ *$//')"
    address_new="$(echo "$line" | awk -F '[|/]' '{print $3}' | sed -e 's/^ *//;s/ *$//')"
    amount_new="$(echo "$line" | awk -F '[|/]' '{print $4}' | sed -e 's/^ *//;s/ *$//;s/^\([0-9]*\).*$/\1/')"

    if [[ "x$first" == "xtrue" ]]; then
        first=
        username="$username_new"
        address="$address_new"
        amount=0
    fi

    if [[ "x$address_new" != "x" ]] && [[ "x$address_new" != "x$address" ]];  then
        echo "// Discord User: $username"
        echo "payeeTable.Add(\"$address\", $amount);"

        totalshares="$(($totalshares + $amount))"

        if [[ "x$username_new" != "x" ]]; then
            username="$username_new"
        fi
        address="$address_new"
        amount="$amount_new"
    else
        if [[ "x$username_new" != "x" ]]; then
            username="$username_new"
        fi
        if [[ "x$address_new" != "x" ]]; then
            address="$address_new"
        fi
        if [[ "x$amount_new" != "x" ]]; then
            amount="$(($amount + $amount_new))"
        fi
    fi

done <<< "$(grep "$file" -e '^.*#.*|.*|.*|.*$' -e '^.*#.*/.*/.*/.*$' | grep -oe '^.*[0-9]')"

echo "// Discord user: $username"
echo "payeeTable.Add(\"$address\", $amount);"
totalshares="$(($totalshares + $amount))"

echo
echo "// Total Shares counted: $totalshares"

