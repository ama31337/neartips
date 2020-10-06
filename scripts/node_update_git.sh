#!/bin/bash

#choose your network
networktype="betanet"

SCRIPT_DIR=`cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P`

OS_SYSTEM=`uname`
if [[ "$OS_SYSTEM" == "Linux" ]];then
    CALL_BC="bc"
else
    CALL_BC="bc -l"
fi

#check node version diff
localversion=$(curl -s http://127.0.0.1:3030/status | jq .version | grep -Po '"version": "\K.*?(?=")' | grep beta | head -1)
gitversion=$(curl --silent "https://api.github.com/repos/nearprotocol/nearcore/releases" | grep -Po '"tag_name": "\K.*?(?=")' | grep beta | head -1)
diff <(echo "$localversion") <(echo "$gitversion")

#start update if local version is different
if [ $? -ne 0 ]; then
    echo "start update";
    rustup default nightly
    rm -rf /home/$USER/nearcore.new
#    strippedversion=$(echo "$gitversion" | awk -F "\"" '{print $2}' | awk -F "-" '{print $1}')
    git clone --branch $gitversion https://github.com/nearprotocol/nearcore.git /home/$USER/nearcore.new
    cd /home/$USER/nearcore.new
    make release
        #if make was succesfully test a new node
        if [ $? -eq 0 ]
        then
            mkdir -p /home/$USER/nearcore.bak
            mv /home/$USER/nearcore /home/$USER/nearcore.bak/nearcore-"`date +"%Y-%m-%d(%H:%M)"`"
            mv /home/$USER/nearcore.new /home/$USER/nearcore
            cd /home/$USER/
            nearup stop
            nearup run $networktype --binary-path /home/$USER/nearcore/target/release/
            mkdir -p /home/$USER/near-logs
#            "${SCRIPT_DIR}/sendmsg_tgbot.sh" "$HOSTNAME inform you:" "update finished, node status: active"  2>&1 > /dev/null
            echo "update done at `date +"%Y-%m-%d(%H:%M)"`" >> /home/$USER/near-logs/near_update.log
        else
            mkdir -p /home/$USER/near-logs
#            "${SCRIPT_DIR}/sendmsg_tgbot.sh" "$HOSTNAME inform you:" "near update failed, check it manually"  2>&1 > /dev/null
            echo "build failed at `date +"%Y-%m-%d(%H:%M)"`" >> /home/$USER/near-logs/near_update.log
        fi
fi
