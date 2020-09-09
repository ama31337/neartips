#!/bin/bash

#choose betanet or testnet
networktype=$betanet

#check node version diff
diff <(curl -s https://rpc.$networktype.near.org/status | jq .version) <(curl -s http://127.0.0.1:3030/status | jq .version)

#start update if local version is different
if [ $? -ne 0 ]; then
    echo "start update";
    rustup default nightly
    rm -rf /home/$USER/nearcore.new
    version=$(curl -s https://rpc.$networktype.near.org/status | jq .version.version)
    strippedversion=$(echo "$version" | awk -F "\"" '{print $2}' | awk -F "-" '{print $1}')
    git clone --branch $strippedversion https://github.com/nearprotocol/nearcore.git /home/$USER/nearcore.new
    cd /home/$USER/nearcore.new
    make release
        #if make make was succesfully startup a new node
        if [ $? -eq 0 ]
        then
            mv /home/$USER/nearcore /home/$USER/nearcore.bak/nearcore-"`date +"%Y-%m-%d(%H:%M)"`"
            mv /home/$USER/nearcore.new /home/$USER/nearcore
            cd /home/near/
            nearup stop
            nearup run $networktype --binary-path ~/nearcore/target/release/
            echo "update done" >> near_update.log
        else
            echo "build failed" >> near_update.log
        fi
fi