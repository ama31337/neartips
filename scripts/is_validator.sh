#!/bin/bash

cd /home/$USER/.near/betanet #for betanet
#cd /home/$USER/.near #for mainnet

diff "validator_key.json.work" "validator_key.json"

if [ $? -eq 0 ];
    then
        echo "local node is validating"
    else
        echo "local node is NOT validating"
fi
