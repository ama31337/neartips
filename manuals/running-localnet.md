---
id: running-localnet
title: Running Near localnet
sidebar_label: Running Near localnet
---

For testing purposes you can run a localnet on your machine with as much nodes as you want.
Default localnet setup whoch you can run simply with 
```sh
nearup localnet
```
will start 4 local nodes and node0 will start on default ports, same as your main validator node if you run on the same machine, so to run a localnet you need to stop your main validator node.

There are solution to run localnet in parallel with your main node:
    - Run those nodes on different ports, which you can setup in config for each of them.
    - Run localnet nodes w/o nearup, so nearup will not start a watcher for new nodes and you can stop them w/o affect your main node.

We are start from the point what you already have a compiled binary of near node on your machine in default directory: /home/$USER/nearcore/target/release/
1. Clone the near-update system
```sh
cd $HOME && git clone https://github.com/ama31337/near-update.git
```
2. Check configs of each node you want to run to be sure you don't use same ports already for any service, as example we check node0:
```sh
vim /home/$USER/near-update/localnet/node0/config.json
```
Edit ports on lines #7 and #29 if current ports are busy, if you run only near node on this machine, you can skip this step, ports in comfigs already edited.

3. Start your first localnet node (you can do it in screen or tmux):
```sh
/home/$USER/nearcore/target/release/neard --home /home/$USER/near-update/localnet/node0 run
```

4. To run more nodes on localnet you need to connect them to the first one (run them in independent tmux sessions to check), you need to know node pubkey, ip and port to connect
    - We run a localnet, so ip is 127.0.0.1, port you can check in step2 on line #29
    - Main node public key you can check in node_key.json:
```sh
cat /home/$USER/near-update/localnet/node0/node_key.json | grep public_key
```
    - After that you can run multiple nodes and connect them to the main one (run each node in different tmux session):
```sh
/home/$USER/nearcore/target/release/neard --home /home/$USER/near-update/localnet/node1 run --boot-nodes ed25519:7PGseFbWxvYVgZ89K1uTJKYoKetWs7BJtbyXDzfbAcqX@127.0.0.1:24550
/home/$USER/nearcore/target/release/neard --home /home/$USER/near-update/localnet/node2 run --boot-nodes ed25519:7PGseFbWxvYVgZ89K1uTJKYoKetWs7BJtbyXDzfbAcqX@127.0.0.1:24550
/home/$USER/nearcore/target/release/neard --home /home/$USER/near-update/localnet/node3 run --boot-nodes ed25519:7PGseFbWxvYVgZ89K1uTJKYoKetWs7BJtbyXDzfbAcqX@127.0.0.1:24550

```
5. Now your nodes will try to connect and you'll see what you've 4 peers. If nodes running fine, blocks counting will start to increase.

! Congratilations, your own NEAR local net is running fine and you can process any tests on it.

6. To stop localnet

Check localnet process id
```sh
ps -e | grep near
```
Main near node will have a name "near" and localnet nodes are "neard", so you can kill them by process numbers:
```sh
kill <id>
```
Or just stop them all at once:
```sh
pkill neard
```

If manual was helpful to you, feel free to donate a tip --> @31337.near
