# TASK: migrate keys, and set up a BACKUP node.

NOTE: first of all stop both servers and then proceed

## Main Server

```
sudo systemctl stop neard
cat .near/node_key.json .near/validator_key.json | grep public
rm .near/node_key.json .near/validator_key.json
cp backup-keys/*.json .near/
cat .near/node_key.json | grep public
sudo systemctl start neard
journalctl -n 100 -f -u neard
```

## Backup Server

```
sudo systemctl stop neard
cat .near/node_key.json | grep public
rm .near/node_key.json
cp validator-keys/*.json .near/
cat .near/node_key.json | grep public
sudo systemctl start neard
journalctl -n 100 -f -u neard
```

Example, screenshots:
Main server - CLI:

<img width="744" alt="Ch-013-main-server-commands" src="https://user-images.githubusercontent.com/29555611/188862331-5bfe96af-bd85-4fdd-a1a3-8155dcd0f071.png">

Backup server - CLI:

<img width="539" alt="Ch-013-backup-server-commands" src="https://user-images.githubusercontent.com/29555611/188862355-5845abb8-483b-4d3e-a67e-10f782c0bae8.png">

Main server - journal:

<img width="1403" alt="Ch-013-main-server-logs" src="https://user-images.githubusercontent.com/29555611/188862370-7d14837c-1eb0-4a3b-9642-ba63512fa87b.png">

Backup server - journal:

<img width="1134" alt="Ch-013-backup-server-logs" src="https://user-images.githubusercontent.com/29555611/188862377-e182c406-640f-4bb2-b544-ed8405a2d31b.png">
