#!/bin/bash

# setup variables
network="mainnet"
export NODE_ENV=$network
POOL_ID="test.poolv1.near"
ACCOUNT_ID="test.near"

SCRIPT_DIR=`cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P`

epoch_start_height=$(curl -sSf \
    -H 'Content-Type: application/json' \
    -d '{"jsonrpc":"2.0","method":"validators","id":"test","params":[null]}' \
    http://127.0.0.1:3030/ | \
  jq -r .result.epoch_start_height)

echo "start: $epoch_start_height"

# epoch holder
epoch_holder="/tmp/epoch_holder.txt"
touch $epoch_holder

# epoch holder init
prev_epoch=$(cat "$epoch_holder")
if [ "$prev_epoch" =  "" ]; then
    prev_epoch=0
fi
echo "prev: $prev_epoch"

# epoch diff and ping
if (($epoch_start_height != $prev_epoch)); then
    mkdir -p /home/$USER/near-logs
    /usr/bin/near call $POOL_ID ping '{}' --accountId $ACCOUNT_ID >> /home/$USER/near-logs/epoch_ping.log
    echo $epoch_start_height > $epoch_holder
fi
