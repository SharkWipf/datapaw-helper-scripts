#!/bin/bash

totalshares=0
file="$1"
first=true

while read line; do
    username_new="$(echo "$line" | awk -F '|' '{print $1}' | sed -e 's/^ *//;s/ *$//')"
    address_new="$(echo "$line" | awk -F '|' '{print $3}' | sed -e 's/^ *//;s/ *$//')"
    amount_new="$(echo "$line" | awk -F '|' '{print $4}' | sed -e 's/^ *//;s/ *$//')"

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

#    echo "$line" | grep -e '^[,]\+$' &>/dev/null
#    if [[ $? -eq 0 ]]; then
#        echo "// Discord user: $username"
#        echo "payeeTable.Add(\"$address\", $amount);"
#        total="$(($total + $amount))"
#        echo "Total: $total"
#        exit
#    fi
done <<< "$(grep "$file" -e '|' | grep -oe '^.*[0-9]')"

echo "// Discord user: $username"
echo "payeeTable.Add(\"$address\", $amount);"
totalshares="$(($totalshares + $amount))"

echo
echo "Total Shares: $totalshares"

