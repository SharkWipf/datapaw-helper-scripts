#!/bin/bash

function varNotEmpty() {
    i=1
    for var in "$@"; do
        if [[ "x$var" == "x" ]]; then
            return $i
        fi
        i=$(($i+1))
    done
}


function generatePayees() {
    username_new="$1"
    txid_new="$2"
    address_new="$3"
    amount_new="$4"

    if [[ "x$initialized" == "x" ]]; then
        username="$username_new"
        txid="$txid_new"
        address="$address_new"
        amount="$amount_new"
        totalshares=0
        totalpaid=0
        initialized=true
        return
    fi


    if [[ "x$username_new" == "x" ]]; then
        username_new="$username"
    fi
    if [[ "x$txid_new" == "x" ]]; then
        txid_new="$txid"
    fi
    if [[ "x$address_new" == "x" ]]; then
        address_new="$address"
    fi
    if [[ "x$amount_new" == "x" ]]; then
        amount_new="0"
    fi


    if [[ "x$address_new" != "x$address" ]] || [[ "x$username_new" != "x$username" ]]; then
        if varNotEmpty "$rxaddress" "$sharesize"; then
            if [[ $paid -gt 0 ]]; then
                paid="$(($paid + $(verifyPayment "$txid" "$rxaddress" 2>/dev/null)))"
            else
                paid="$(verifyPayment "$txid" "$rxaddress" 2>/dev/null)"
            fi
            totalpaid="$(($totalpaid + $paid))"
            shares="$(($paid / $sharesize))"
            if [[ "x$shares" != "x$amount" ]]; then
                tput bold
                tput setaf 1
                echo "$username: Paid: $paid, $shares / $amount shares."
                tput sgr0
            else
                echo "$username: Paid: $paid, $shares / $amount shares."
            fi
            paid=0
        else
            echo "// Discord user: $username"
            echo "payeeTable.Add(\"$address\", $amount);"
        fi

        totalshares="$(($totalshares + $amount))"
        amount=0
    elif [[ "x$txid_new" != "x$txid" ]]; then
        if varNotEmpty "$rxaddress" "$sharesize"; then
            paid="$(($paid + $(verifyPayment "$txid" "$rxaddress" 2>/dev/null)))"
        fi
    fi

    username="$username_new"
    txid="$txid_new"
    address="$address_new"
    amount="$(($amount + $amount_new))"
}

function verifyPayment() {
    txid="$1"
    rxaddress="$2"

    tx="$(straks-cli getrawtransaction "$txid" true)"

    voutid="$(echo "$tx" | gron | grep -e "$rxaddress" | sed -e 's/json\.vout\[\([0-9]\+\)\]\.scriptPubKey\.addresses\[\([0-9]\+\)\].*$/\1/')"
    value="$(echo "$tx"  | gron | grep -e "json\.vout\[$voutid\]\.value = " | sed -e 's/^.* = \([^;\.]*\).*$/\1/')"
    if varNotEmpty "$value"; then
        echo $value
    else
        echo 0
    fi
}
