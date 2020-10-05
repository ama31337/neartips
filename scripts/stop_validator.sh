#!/bin/bash

#betanet
nearup stop
cp /home/$USER/.near/betanet/validator_key.json.res /home/$USER/.near/betanet/validator_key.json
cp /home/$USER/.near/betanet/node_key.json.res /home/$USER/.near/betanet/node_key.json
nearup run betanet --binary-path ~/nearcore/target/release/

#mainnet
#sudo systemctl stop neard.service
#cp /home/$USER/.near/validator_key.json.res /home/$USER/.near/validator_key.json
#cp /home/$USER/.near/node_key.json.res /home/$USER/.near/node_key.json
#sudo systemctl start neard.service

echo "done"
