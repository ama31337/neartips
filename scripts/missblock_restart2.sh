#!/bin/bash

# TRY AT YOUR OWN RISK, SCRIPT IS NOT TESTED

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
misslimit1=5 # restart after
misslimit2=50 # restart second time

SCRIPT_DIR=`cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P`

# diff check
block_diff=$(curl -d '{"jsonrpc": "2.0", "method": "validators", "id": "dontcare", "params": [null]}' -H 'Content-Type: application/json' https://rpc.$network.near.org | jq -c '.result.current_validators[] | select(.account_id | contains ("'$POOL_ID'"))' | jq '.num_expected_blocks - .num_produced_blocks');
echo "Block difference: $block_diff"
if [ "$block_diff" =  "" ]; then
    block_diff=0
fi

# status holder
STATUS_HOLDER1="/tmp/status1.txt"
STATUS_HOLDER2="/tmp/status2.txt"
touch $STATUS_HOLDER1
touch $STATUS_HOLDER2

# status1 init
st1=$(cat "$STATUS_HOLDER1")
if [ "$st1" =  "" ]; then
    st1=0
fi

# status2 init
st2=$(cat "$STATUS_HOLDER2")
if [ "$st2" =  "" ]; then
    st2=0
fi

# if miss more than $misslimit1 blocks, restart node 1st time
if (($block_diff>=$misslimit1)) && (($st1 == 0)) ; then
  mkdir -p /home/$USER/near-logs
  cp /home/$USER/.near/data/LOG /home/$USER/near-logs/
  sudo journalctl -u neard.service > /home/$USER/near-logs/neard_service.log
  sudo systemctl stop neard.service
  sudo systemctl start neard.service
  echo "node restarted `date +"%Y-%m-%d(%H:%M)"`" >> /home/$USER/near-logs/node_restart.log
  echo 1 > $STATUS_HOLDER1
  "${SCRIPT_DIR}/sendmsg_tgbot.sh" "$HOSTNAME inform you:" "Near node restarted because of $block_diff missed blocks"  2>&1 > /dev/null
fi

# if miss more than $misslimit2 blocks, restart node 2nd time
if (($block_diff>=$misslimit2)) && (($st2 == 0)) ; then
  mkdir -p /home/$USER/near-logs
  cp /home/$USER/.near/data/LOG /home/$USER/near-logs/
  sudo journalctl -u neard.service > /home/$USER/near-logs/neard_service.log
  sudo systemctl stop neard.service
  sudo systemctl start neard.service
  echo "node restarted `date +"%Y-%m-%d(%H:%M)"`" >> /home/$USER/near-logs/node_restart.log
  echo 1 > $STATUS_HOLDER2
  "${SCRIPT_DIR}/sendmsg_tgbot.sh" "$HOSTNAME inform you:" "Near node restarted because of $block_diff missed blocks"  2>&1 > /dev/null
fi

# reset state
if (($block_diff == 0)); then
    echo 0 > $STATUS_HOLDER1
    echo 0 > $STATUS_HOLDER2
fi
