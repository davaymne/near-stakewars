# Setup Validator

### Setup your node

#### Install required software & set the configuration

##### Prerequisites:
Before you start, you may want to confirm that your machine has the right CPU features. 

```
lscpu | grep -P '(?=.*avx )(?=.*sse4.2 )(?=.*cx16 )(?=.*popcnt )' > /dev/null \
  && echo "Supported" \
  || echo "Not supported"
```
> Supported

##### Install developer tools:
```
sudo apt install -y git binutils-dev libcurl4-openssl-dev zlib1g-dev libdw-dev libiberty-dev cmake gcc g++ python3 docker.io protobuf-compiler libssl-dev pkg-config clang llvm cargo
```
#####  Install Python pip:

```
sudo apt install python3-pip
```
##### Set the configuration:

```
USER_BASE_BIN=$(python3 -m site --user-base)/bin
export PATH="$USER_BASE_BIN:$PATH"
```

##### Install Building env
```
sudo apt install clang build-essential make
```

##### Install Rust & Cargo
```
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

When you see the following:

<img width="391" alt="Screenshot 2022-07-31 at 01 05 43" src="https://user-images.githubusercontent.com/29555611/182004141-1bbdd3a9-de14-4a26-aaad-0678ea1b870e.png">

Press 1 and press enter.

##### Source the environment
```
source $HOME/.cargo/env
```

#### Clone `nearcore` project from GitHub
Clone the [`nearcore` repository](https://github.com/near/nearcore).

```
git clone https://github.com/near/nearcore
cd nearcore
git fetch
```

Checkout to the commit needed. Please refer to the commit defined in [this file](https://github.com/near/stakewars-iii/blob/main/commit.md). 
```
git checkout <commit>
```

#### Compile `nearcore` binary
In the `nearcore` folder run the following commands:

```
cargo build -p neard --release --features shardnet
```
The binary path is `target/release/neard`. If you are seeing issues, it is possible that cargo command is not found. Compiling `nearcore` binary may take a little while.

#### Initialize working directory

In order to work properly, the NEAR node requires a working directory and a couple of configuration files. Generate the initial required working directory by running:

```
./target/release/neard --home ~/.near init --chain-id shardnet --download-genesis
```

<img width="1438" alt="Screenshot 2022-07-31 at 01 01 04" src="https://user-images.githubusercontent.com/29555611/182004028-e5e27c11-506f-4132-9499-333c0dafcc5d.png">


This command will create the directory structure and will generate `config.json`, `node_key.json`, and `genesis.json` on the network you have passed. 

- `config.json` - Configuration parameters which are responsive for how the node will work. The config.json contains needed information for a node to run on the network, how to communicate with peers, and how to reach consensus. Although some options are configurable. In general validators have opted to use the default config.json provided.

- `genesis.json` - A file with all the data the network started with at genesis. This contains initial accounts, contracts, access keys, and other records which represents the initial state of the blockchain. The genesis.json file is a snapshot of the network state at a point in time. In contacts accounts, balances, active validators, and other information about the network. 

- `node_key.json` -  A file which contains a public and private key for the node. Also includes an optional `account_id` parameter which is required to run a validator node (not covered in this doc).

- `data/` -  A folder in which a NEAR node will write it's state.

#### Replace the `config.json`

From the generated `config.json`, there are two parameters to modify:
- `boot_nodes`: If you had not specify the boot nodes to use during init in Step 3, the generated `config.json` shows an empty array, so we will need to replace it with a full one specifying the boot nodes.
- `tracked_shards`: In the generated `config.json`, this field is an empty. You will have to replace it to `"tracked_shards": [0]`

```
rm ~/.near/config.json
wget -O ~/.near/config.json https://s3-us-west-1.amazonaws.com/build.nearprotocol.com/nearcore-deploy/shardnet/config.json
```

#### Get latest snapshot

Download snapshot (genesis.json)
```
cd ~/.near
wget https://s3-us-west-1.amazonaws.com/build.nearprotocol.com/nearcore-deploy/shardnet/genesis.json
```

### Activating the node as validator

##### Authorize Wallet Locally

A full access key needs to be installed locally to be able to sign transactions via NEAR-CLI.


* You need to run this command:

```
near login
```

> Note: This command launches a web browser allowing for the authorization of a full access key to be copied locally.

– Copy the link in your browser

<img width="1170" alt="Screenshot 2022-07-31 at 01 09 01" src="https://user-images.githubusercontent.com/29555611/182004224-dcc9f665-5046-41f3-a037-6de77fdbe5d2.png">

– Grant Access to Near CLI

– After Grant, you will see a page like this `This site can't be reached`, go back to console

<img width="652" alt="Screenshot 2022-07-31 at 01 18 31" src="https://user-images.githubusercontent.com/29555611/182004406-d7cad9d3-bf92-4506-b260-72ba959b7301.png">

- Enter your wallet `<NAME>.shardnet.near` and press Enter


#####  Create the validator_key.json

Create a `validator_key.json` 

*   Generate the Key file:

```
near generate-key <pool_id>
```
<pool_id> ---> xx.factory.shardnet.near WHERE xx is you pool name

* Copy the file generated to shardnet folder:
Make sure to replace <pool_id> by your accountId
```
cp ~/.near-credentials/shardnet/YOUR_WALLET.json ~/.near/validator_key.json
```
* Edit “account_id” => xx.factory.shardnet.near, where xx is your PoolName
* Change `private_key` to `secret_key`

> Note: The account_id must match the staking pool contract name or you will not be able to sign blocks.\

File content must be in the following pattern:
```
{
  "account_id": "xx.factory.shardnet.near",
  "public_key": "ed25519:HeaBJ3xLgvZacQWmEctTeUqyfSU4SDEnEwckWxd92W2G",
  "secret_key": "ed25519:****"
}
```

#####  Start the validator node

```
target/release/neard run
```
* Setup Systemd
Command:

```
sudo vi /etc/systemd/system/neard.service
```
Paste:

```
[Unit]
Description=NEARd Daemon Service

[Service]
Type=simple
User=<USER>
WorkingDirectory=/home/<USER>/.near
ExecStart=/home/<USER>/nearcore/target/release/neard run
Restart=on-failure
RestartSec=30
KillSignal=SIGINT
TimeoutStopSec=45
KillMode=mixed

[Install]
WantedBy=multi-user.target
```

> Note: Change USER to your paths

Command:

```
sudo systemctl enable neard
```
Command:

```
sudo systemctl start neard
```
If you need to make a change to service because of an error in the file. It has to be reloaded:

```
sudo systemctl reload neard
```
###### Watch logs
Command:

```
journalctl -n 100 -f -u neard
```
Output example:

<img width="1436" alt="Screenshot 2022-07-31 at 02 48 29" src="https://user-images.githubusercontent.com/29555611/182006224-4de78741-3196-4953-a9e9-efb9df748c61.png">


Make log output in pretty print

Command:

```
sudo apt install ccze
```
View Logs with color

Command:

```
journalctl -n 100 -f -u neard | ccze -A
```
#### Becoming a Validator
In order to become a validator and enter the validator set, a minimum set of success criteria must be met.

* The node must be fully synced
* The `validator_key.json` must be in place
* The contract must be initialized with the public_key in `validator_key.json`
* The account_id must be set to the staking pool contract id
* There must be enough delegations to meet the minimum seat price. See the seat price [here](https://explorer.shardnet.near.org/nodes/validators).
* A proposal must be submitted by pinging the contract
* Once a proposal is accepted a validator must wait 2-3 epoch to enter the validator set
* Once in the validator set the validator must produce great than 90% of assigned blocks
