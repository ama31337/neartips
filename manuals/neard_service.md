Recommended way to run your validtor node is via systemd service, change "<user>" to the actual one
```
sudo vim /etc/systemd/system/neard.service
```
```
[Unit]
Description=neard service
After=network.target

[Service]
User=<user>
ExecStart=/home/<user>/nearcore/target/release/neard run

[Install]
WantedBy=default.target
```
Enable and start (you can use stop as well)
```
sudo systemctl enable neard.service
sudo systemctl start neard.service
```
To check logs
```
sudo journalctl -u neard.service -f
```
