#!/bin/bash

# sript to restart valdiator node in case of missed blocks

# setup variables
network="betanet"
export NODE_ENV=$network
POOL_ID="infinite.lux.near"
misslimit=5 # restart after

SCRIPT_DIR=`cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P`

# diff check
expected_blocks=$(curl -sSf \
    -H 'Content-Type: application/json' \
    -d '{"jsonrpc":"2.0","method":"validators","id":"test","params":[null]}' \
    http://127.0.0.1:3030/ | \
    jq -c '.result.current_validators[] | select(.account_id | contains  ("'$POOL_ID'"))' | jq .num_expected_blocks)
#echo "expect: $expected_blocks"

produced_blocks=$(curl -sSf \
    -H 'Content-Type: application/json' \
    -d '{"jsonrpc":"2.0","method":"validators","id":"test","params":[null]}' \
    http://127.0.0.1:3030/ | \
    jq -c '.result.current_validators[] | select(.account_id | contains  ("'$POOL_ID'"))' | jq .num_produced_blocks)
#echo "expect: $produced_blocks"

block_diff=$(($expected_blocks - $produced_blocks))
#echo "Block difference: $block_diff"

if [ "$block_diff" =  "" ]; then
    block_diff=0
fi

# status holder
STATUS_HOLDER="/tmp/$POOL_ID.txt"
touch $STATUS_HOLDER

# status init
st=$(cat "$STATUS_HOLDER")
if [ "$st" =  "" ]; then
    st=0
fi

# if miss more than $misslimit blocks, restart node
if (($block_diff>=$misslimit)) && (($st == 0)) ; then
  mkdir -p /home/$USER/near-logs
#  cp /home/$USER/.near/data/LOG /home/$USER/near-logs/
#  sudo journalctl -u neard.service > /home/$USER/near-logs/neard_service.log
  nearup stop
  nearup run $network
  echo "node restarted `date +"%Y-%m-%d(%H:%M)"`" >> /home/$USER/near-logs/node_restart.log
  echo 1 > $STATUS_HOLDER
  "${SCRIPT_DIR}/sendmsg_tgbot.sh" "$HOSTNAME inform you:" "Near $network node restarted because of $block_diff missed blocks"  2>&1 > /dev/null
fi

# reset state
if (($block_diff == 0)); then
    echo 0 > $STATUS_HOLDER
fi
