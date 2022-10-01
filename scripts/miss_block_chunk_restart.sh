#!/bin/bash

# sript to restart valdiator node in case of missed blocks
# to execute systemctl add nopasswd execution for sudo users:
# sudo vim /etc/sudoers
# %sudo  ALL=(ALL) NOPASSWD: ALL
# to setup neard service read manuals section
# for telegram alerts put sendmsg_tgbot.sh in the same folder



# setup variables
network="mainnet"
export NODE_ENV=${network}
POOL_ID="lux.poolv1.near"
missed_blocks_1=5 # restart after missed x blocks
missed_blocks_2=25 # restart after missed xx blocks
missed_chunks_1=5
missed_chunks_2=25

SCRIPT_DIR=`cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P`

# blocks diff check
block_diff=$(curl -d '{"jsonrpc": "2.0", "method": "validators", "id": "dontcare", "params": [null]}' -H 'Content-Type: application/json' https://rpc.$network.near.org | jq -c '.result.current_validators[] | select(.account_id | contains ("'$POOL_ID'"))' | jq '.num_expected_blocks - .num_produced_blocks');
echo "Block difference: ${block_diff}"
if [ "${block_diff}" =  "" ]; then
    block_diff=0
fi

# chunks diff check
chunk_diff=$(curl -d '{"jsonrpc": "2.0", "method": "validators", "id": "dontcare", "params": [null]}' -H 'Content-Type: application/json' https://rpc.$network.near.org | jq -c '.result.current_validators[] | select(.account_id | contains ("'$POOL_ID'"))' | jq '.num_expected_chunks - .num_produced_chunks');
echo "Chunks difference: ${chunk_diff}"
if [ "${chunk_diff}" =  "" ]; then
    chunk_diff=0
fi


# status holder
BLOCK_STATUS_HOLDER1="/tmp/block_status1.txt"
BLOCK_STATUS_HOLDER2="/tmp/block_status2.txt"
CHUNK_STATUS_HOLDER1="/tmp/chunk_status1.txt"
CHUNK_STATUS_HOLDER2="/tmp/chunk_status2.txt"
touch ${BLOCK_STATUS_HOLDER1} ${BLOCK_STATUS_HOLDER2} ${CHUNK_STATUS_HOLDER1} ${CHUNK_STATUS_HOLDER2}

# status init
bl_st1=$(cat "${BLOCK_STATUS_HOLDER1}")
if [ "${bl_st1}" =  "" ]; then
    bl_st1=0
fi

bl_st2=$(cat "${BLOCK_STATUS_HOLDER2}")
if [ "${bl_st2}" =  "" ]; then
    bl_st2=0
fi

ch_st1=$(cat "${CHUNK_STATUS_HOLDER1}")
if [ "${ch_st1}" =  "" ]; then
    ch_st1=0
fi

ch_st2=$(cat "${CHUNK_STATUS_HOLDER2}")
if [ "${ch_st2}" =  "" ]; then
    ch_st2=0
fi


# if miss more than $missed_blocks_1 blocks, restart node 1st time
if (( ${block_diff} >= ${missed_blocks_1} )) && ((${bl_st1} == 0)) ; then
  echo 1 > ${BLOCK_STATUS_HOLDER1}
  mkdir -p ${HOME}/near-logs
#  cp ${HOME}/.near/data/LOG ${HOME}/near-logs/
#  sudo journalctl -u neard.service > ${HOME}/near-logs/neard_service.log
  sudo systemctl restart neard.service
  echo "node restarted `date +"%Y-%m-%d(%H:%M)"`" >> ${HOME}/near-logs/node_restart.log
  "${SCRIPT_DIR}/sendmsg_tgbot.sh" "${HOSTNAME} inform you:" "Near node restarted because of ${block_diff} missed blocks"  2>&1 > /dev/null
fi

# if miss more than $missed_blocks_2 blocks, restart node 2nd time
if (( ${block_diff} >= ${missed_blocks_2} )) && (($st2 == 0)) ; then
  echo 1 > ${BLOCK_STATUS_HOLDER2}
  mkdir -p ${HOME}/near-logs
#  cp ${HOME}/.near/data/LOG ${HOME}/near-logs/
#  sudo journalctl -u neard.service > ${HOME}/near-logs/neard_service.log
  sudo systemctl restart neard.service
  echo "node restarted `date +"%Y-%m-%d(%H:%M)"`" >> ${HOME}/near-logs/node_restart.log
  "${SCRIPT_DIR}/sendmsg_tgbot.sh" "${HOSTNAME} inform you:" "Near node restarted because of ${block_diff} missed blocks"  2>&1 > /dev/null
fi

# if miss more than $missed_chunks_1 chunks, restart node 1st time
if (( ${chunk_diff} >= ${missed_chunks_1} )) && ((${bl_st1} == 0)) ; then
  echo 1 > ${CHUNK_STATUS_HOLDER1}
  mkdir -p ${HOME}/near-logs
#  cp ${HOME}/.near/data/LOG ${HOME}/near-logs/
#  sudo journalctl -u neard.service > ${HOME}/near-logs/neard_service.log
  sudo systemctl restart neard.service
  echo "node restarted `date +"%Y-%m-%d(%H:%M)"`" >> ${HOME}/near-logs/node_restart.log
  "${SCRIPT_DIR}/sendmsg_tgbot.sh" "${HOSTNAME} inform you:" "Near node restarted because of ${chunk_diff} missed chunks"  2>&1 > /dev/null
fi

# if miss more than $missed_chunks_2 chunks, restart node 2nd time
if (( ${chunk_diff} >= ${missed_chunks_2} )) && (($st2 == 0)) ; then
  echo 1 > ${CHUNK_STATUS_HOLDER2}
  mkdir -p ${HOME}/near-logs
#  cp ${HOME}/.near/data/LOG ${HOME}/near-logs/
#  sudo journalctl -u neard.service > ${HOME}/near-logs/neard_service.log
  sudo systemctl restart neard.service
  echo "node restarted `date +"%Y-%m-%d(%H:%M)"`" >> ${HOME}/near-logs/node_restart.log
  "${SCRIPT_DIR}/sendmsg_tgbot.sh" "${HOSTNAME} inform you:" "Near node restarted because of ${chunk_diff} missed chunks"  2>&1 > /dev/null
fi

# reset state
if ((${block_diff} == 0)); then
    echo 0 > ${BLOCK_STATUS_HOLDER1}
    echo 0 > ${BLOCK_STATUS_HOLDER2}
fi

if ((${chunk_diff} == 0)); then
    echo 0 > ${CHUNK_STATUS_HOLDER1}
    echo 0 > ${CHUNK_STATUS_HOLDER2}
fi
