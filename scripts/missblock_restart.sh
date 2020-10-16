#!/bin/bash
export NODE_ENV=mainnet
POOL_ID="test.poolv1.near"
misslimit=5
block_diff=$(curl -d '{"jsonrpc": "2.0", "method": "validators", "id": "dontcare", "params": [null]}' -H 'Content-Type: application/json' https://rpc.betanet.near.org | jq -c '.result.current_validators[] | select(.account_id | contains ("$POOL_ID"))' | jq '.num_expected_blocks - .num_produced_blocks');
echo "Block difference: $block_diff"

STATUS_HOLDER="/tmp/$POOL_ID.txt"
touch $STATUS_HOLDER

#check status
st=$(cat "$STATUS_HOLDER")
if [ "$st" =  "" ]; then
        st=$(echo 0)
fi

# if miss more than $misslimit blocks, restart node
if (($block_diff>$misslimit)) && (($st == 0)) ; then
  sudo systemctl stop neard.service
  sudo systemctl start neard.service
  echo "node restarted `date +"%Y-%m-%d(%H:%M)"`" >> /home/$USER/near-logs/node_restart.log
  echo 1 > $STATUS_HOLDER
fi

#reset state
if [ "$block_diff" == "" ]; then
    echo 0 > $STATUS_HOLDER
fi