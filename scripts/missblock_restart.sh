#!/bin/bash

# sript to restart valdiator node in case of missed blocks
# to execute systemctl add nopasswd execution for sudo users:
# sudo vim /etc/sudoers
# %sudo  ALL=(ALL) NOPASSWD: ALL
# to setup neard service read manuals section
# for telegram alerts put sendmsg_tgbot.sh in the same folder
# credits to @ama31337 and @denys4k


# setup variables
network="mainnet"
export NODE_ENV=$network
POOL_ID="test.poolv1.near"
misslimit=5 # restart after

SCRIPT_DIR=`cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P`

# diff check
block_diff=$(curl -d '{"jsonrpc": "2.0", "method": "validators", "id": "dontcare", "params": [null]}' -H 'Content-Type: application/json' https://rpc.$network.near.org | jq -c '.result.current_validators[] | select(.account_id | contains ("$POOL_ID"))' | jq '.num_expected_blocks - .num_produced_blocks');
echo "Block difference: $block_diff"

# status holder
STATUS_HOLDER="/tmp/$POOL_ID.txt"
touch $STATUS_HOLDER

# status init
st=$(cat "$STATUS_HOLDER")
if [ "$st" =  "" ]; then
        st=$(echo 0)
fi

# if miss more than $misslimit blocks, restart node
if (($block_diff>=$misslimit)) && (($st == 0)) ; then
  sudo systemctl stop neard.service
  sudo systemctl start neard.service
  mkdir -p /home/$USER/near-logs
  echo "node restarted `date +"%Y-%m-%d(%H:%M)"`" >> /home/$USER/near-logs/node_restart.log
  echo 1 > $STATUS_HOLDER
  "${SCRIPT_DIR}/sendmsg_tgbot.sh" "$HOSTNAME inform you:" "Near node restarted because of $block_diff missed blocks"  2>&1 > /dev/null
fi

# reset state
if [ "$block_diff" == "" ]; then
    echo 0 > $STATUS_HOLDER
fi
