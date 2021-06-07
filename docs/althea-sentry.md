# How to set up an Althea Sentry node

**NOTE:** This guide assumes that you already have an Althea Validator set up and running. If you do not have that yet, [follow these instructions to set up an Althea Validator node](https://github.com/althea-net/althea-chain/blob/main/docs/althea/althea-testnet-docs/setting-up-a-validator-manual.md).

_Adapted from [Paul Lovette](https://github.com/lightiv)'s [Linux Install guide](https://github.com/lightiv/SkyNet/wiki/Ubuntu-Linux-Install-Guide) and his [Akash Sentry setup guide](https://github.com/lightiv/SkyNet/wiki/Validator-Sentry-Setup-With-Best-Practice)_

## What is a Sentry node?
A Sentry node is a type of node that handles the traffic for a validator. As far as I understand, it helps manage the load on the overall network when other validators are joining.

# Part 1: Set up the Sentry host machine

_Note:_ The Sentry node must have its own IP address, and ideally be on a separate network (up/download line) from your other Sentries (ideally, geographically or globally distributed).

* The own IP address is a requirement because the Sentry node needs to exist separately on the Althea network from your other sentries.
* The separate network is a requirement because that is what will help distribute the traffic/load on the Althea validator network.

It **may** be possible to run a **cluster** of sentries behind one IP address using **Kubernetes**, however I have not tried that yet.

## Set up a new linux host

Get a new linux host (Linode, AWS LightSail, DigitalOcean, Vultr, whatever...) running at least Ubuntu 20.04.

### 1.1 Set your hostname

Sample values for the below commands:

* `NEW_HOSTNAME`: `althea-sentry-01`

`sudo hostnamectl set-hostname NEW_HOSTNAME`

Edit the hosts file and add your new hostname to map to 127.0.0.1.

`sudo vim /etc/hosts`

Add the following line at the top of the file:

`127.0.0.1     NEW_HOSTNAME`

Press `ESC` to enter command mode, then type `:wq` and hit `ENTER` to save the file and quit the editor.

Reboot your new machine: `sudo reboot`

### 1.2 Add the (non-root) sentry user

Sample values for the below commands:

* `USERNAME`: `altheasentry`

```shell
sudo useradd USERNAME
sudo passwd USERNAME
usermod -aG sudo USERNAME
```

Grant `sudo` permission scope to the new user:

`sudo visudo`

Add an entry for the new user under "User privilege specification":

`USERNAME    ALL=(ALL:ALL) ALL`

Add the new user's home directory and set the permissions on that directory:

```shell
sudo mkdir /home/USERNAME/
sudo chown -R USERNAME:USERNAME /home/USERNAME/
```

Set the new user's login shell to bash:

`chsh -s /bin/bash USERNAME`

### 1.3 Update and hardening

```shell
sudo apt update
sudo apt dist-upgrade`
sudo apt install -y unzip net-tools build-essential libssl-dev
```

#### Configure the firewall (ufw, the "uncomplicated firewall")

Check if the firewall `ufw` is enabled: `sudo ufw status`

**IF the firewall is NOT enabled, continue with this "configure the firewall" section. Otherwise, continue to the next section, ["Part 2: Validator Sentry Setup"](#part-2-validator-sentry-setup).**

Disable the firewall at first, make modifications, then bring it back up.

So, first disable the firewall:

`sudo ufw disable`

Set the defaults for incoming/outgoing ports:

```shell
sudo ufw default deny incoming
sudo ufw default allow outgoing
```

Open up the SSH port:

`sudo ufw allow from any to any port 22 proto tcp`

Double-check the port you are opening for ssh is the same as what is set in `/etc/ssh/sshd_config`. You can change the ssh port in `/etc/ssh/sshd_config` if you like, just remember to open the port on the firewall as well.

Check the ssh port:

`cat /etc/ssh/sshd_config | grep Port`

Turn the firewall back on:

```shell
sudo ufw enable
sudo ufw status verbose
```

Make sure you see the ssh port in the allowed rules!

Finally, reboot: `sudo reboot`

# Part 2: Validator Sentry Setup

_NOTE: I'm adapting the following instructions from the [official Althea fullnode setup instructions](https://github.com/althea-net/althea-chain/blob/main/docs/althea/althea-testnet-docs/setting-up-a-fullnode-manual.md), and Paul's Sentry instructions linked at the beginning of this document._

Requirements: 

* 2 GB RAM
* 20 GB storage

## Set up an Althea fullnode

Follow the [official Althea fullnode setup instructions](https://github.com/althea-net/althea-chain/blob/main/docs/althea/althea-testnet-docs/setting-up-a-fullnode-manual.md) **BUT DO NOT** run `althea start` yet!

Specifically, follow these sections:

1. [Download the Althea chain software](https://github.com/althea-net/althea-chain/blob/main/docs/althea/althea-testnet-docs/setting-up-a-fullnode-manual.md#download-althea-chain-software)

2. [Initialize the config files](https://github.com/althea-net/althea-chain/blob/main/docs/althea/althea-testnet-docs/setting-up-a-fullnode-manual.md#init-the-config-files)

_Note about the official docs:_ `mymoniker` is the name you have given your validator (via your sentry). In my case, I named my sentry the same moniker as my validator. I have not tested what happens if your validator and sentry have different monikers.

3. [Copy the genesis file](https://github.com/althea-net/althea-chain/blob/main/docs/althea/althea-testnet-docs/setting-up-a-fullnode-manual.md#copy-the-genesis-file)

4. [Add seed node](https://github.com/althea-net/althea-chain/blob/main/docs/althea/althea-testnet-docs/setting-up-a-fullnode-manual.md#add-seed-node)

## Configure the fullnode into a sentry node

### 2.1 Check CPU instruction set for `rdseed` instruction

`cat /proc/cpuinfo | grep flags | grep rdseed`

Your CPU should have the `rdseed` instruction listed.

### 2.2 Open required sentry firewall ports

Inbound (Sentry):

* ssh (22 or whatever port you set for ssh on your Sentry) from anywhere: `sudo ufw allow from any to any port 22 proto tcp`
* althea p2p (26656) from anywhere: `sudo ufw allow from any to any port 26656 proto tcp`
* althea rpc (26657) from anywhere: `sudo ufw allow from any to any port 26657 proto tcp`

Inbound (**Validator**) (⚠️ yes the validator needs specific ports open too!):

* ssh (22 or whatever port you chose) from anywhere: `sudo ufw allow from any to any port 22 proto tcp`
* althea p2p (26656) from **your sentry IP only**: `sudo ufw allow from SENTRY_IP to any port 26656 proto tcp`
* Paul's Sentry guide mentions opening port 26657 to a "MONITORING NODE", but I don't know of any monitoring node for the Althea network. I might modify this guide in the future with more information about this as I learn more.

### 2.3 `config.toml` and `app.toml`

_Notes about values in these config files:_

* `external_address` is an IP address or FQDN
* `private_peer_ids` can be acquired by running `althea tendermint show-node-id` on your **validator**, example: `23eeeeee84bbb701a34b1fffff09e79ccccc3aaa`
* `persistent_peers` are _full addresses_, example: `23eeeeee84bbb701a34b1fffff09e79ccccc3aaa@althea.domain.net:26656,23effffe84bbbccca34b1aaaaa09e79bbbbb3ccc@althea.domain2.net:26656`
* `unconditional_peer_ids` are Tendermint node IDs (hex values), which can be acquired by running `althea tendermint show-node-id` on each sentry/validator. Example: `23eeeeee84bbb701a34b1fffff09e79ccccc3aaa,23effffe84bbbccca34b1aaaaa09e79bbbbb3ccc`

#### On your **sentry**, you need to set the following settings in `~/.althea/config/config.toml`:

```toml
pex = true
max_open_connections = 200
external_address = "YOUR_SENTRY_PUBLIC_IP_OR_FQDN:26656"
private_peer_ids = "TENDERMINT_NODE_ID_OF_VALIDATOR" # Remember, this is a hex value, not an IP address
laddr = "tcp://0.0.0.0:26667" # This is changed from the default (26657) because we will use nginx for DoS prevention later in these instructions
persistent_peers = "YOUR_VALIDATOR_AND_SENTRIES_FULL_ADDRESSES" # These are combined hex values AND IP addresses/FQDNs!
unconditional_peer_ids = "YOUR_VALIDATORS_AND_SENTRIES" # NOTE: These are TENDERMINT NODE IDs (hex value), NOT IP ADDRESSES!
prometheus = true
prometheus_listen_addr = ":26660"
```

#### On your **sentry**, you need to set the following setting in `~/.althea/config/app.toml`:

```toml
minimum-gas-prices = "1ualtg"
```

#### On your **validator**, you need to set the following settings in `config.toml`.

Stop the althea service/binary and edit `~/.althea/config/config.toml`, then start the althea service/binary again at the end of these instructions, after starting your sentry:

```toml
pex = false
max_open_connections = 3
external_address = "YOUR_SENTRY_PUBLIC_IP_OR_FQDN:26656"
unconditional_peer_ids = "YOUR_VALIDATORS_AND_SENTRIES" # NOTE: These are TENDERMINT NODE IDs (hex value), NOT IP ADDRESSES!
prometheus = true
prometheus_listen_addr = ":26660"
```

### 2.4 NGINX Rate Control, only on the Sentry, since the Validator is protected by the Sentry

Install nginx:

`sudo apt install nginx`

Back up the original `nginx.conf` config file:

`sudo cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bak`

Empty the contents of `nginx.conf`:

`sudo echo "" > /etc/nginx/nginx.conf`

Open the `nginx.conf` config file:

`sudo vim /etc/nginx/nginx.conf`

Press `i` to enter `text insert` mode and paste the following contents into `nginx.conf`:

```
user www-data;
worker_processes auto;
pid /run/nginx.pid;
include /etc/nginx/modules-enabled/*.conf;

events {
        worker_connections 768;
        # multi_accept on;
}

http {

        # Rate Limiting - Protection from DDoS

        limit_req_zone $binary_remote_addr zone=req_zone:10m rate=5r/s;

        upstream rpc_nodes {
          least_conn;
          server 127.0.0.1:26667;
        }

        map $http_upgrade $connection_upgrade {
          default upgrade;
          '' close;
        }

        server {
          listen 26657;
          location / {

            limit_req zone=req_zone burst=20 nodelay;

            proxy_pass http://rpc_nodes;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection $connection_upgrade;
            proxy_set_header Host $host:26657;
          }
        }


        ##
        # Basic Settings
        ##

        sendfile on;
        tcp_nopush on;
        tcp_nodelay on;
        keepalive_timeout 65;
        types_hash_max_size 2048;
        # server_tokens off;

        # server_names_hash_bucket_size 64;
        # server_name_in_redirect off;

        include /etc/nginx/mime.types;
        default_type application/octet-stream;

        ##
        # SSL Settings
        ##

        ssl_protocols TLSv1 TLSv1.1 TLSv1.2 TLSv1.3; # Dropping SSLv3, ref: POODLE
        ssl_prefer_server_ciphers on;

        ##
        # Logging Settings
        ##

        access_log /var/log/nginx/access.log;
        error_log /var/log/nginx/error.log;

        ##
        # Gzip Settings
        ##

        gzip on;

        # gzip_vary on;
        # gzip_proxied any;
        # gzip_comp_level 6;
        # gzip_buffers 16 8k;
        # gzip_http_version 1.1;
        # gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;

        ##
        # Virtual Host Configs
        ##

        include /etc/nginx/conf.d/*.conf;
        include /etc/nginx/sites-enabled/*;
}

#mail {
#       # See sample authentication script at:
#       # http://wiki.nginx.org/ImapAuthenticateWithApachePhpScript
#
#       # auth_http localhost/auth.php;
#       # pop3_capabilities "TOP" "USER";
#       # imap_capabilities "IMAP4rev1" "UIDPLUS";
#
#       server {
#               listen     localhost:110;
#               protocol   pop3;
#               proxy      on;
#       }
#
#       server {
#               listen     localhost:143;
#               protocol   imap;
#               proxy      on;
#       }
#}
```

Press `ESC` in `vim` to exit `text insert` mode, and type `:wq` then press `ENTER` to save and quit `vim`.

Confirm there are no errors in the nginx config:

`sudo nginx -t`

Restart nginx:

`sudo systemctl restart nginx`

### 2.5 Add a `systemd` service for the Sentry

Edit a new `systemd` service file:

`sudo vim /etc/systemd/system/althea-sentry.service`

Paste these contents into `althea-sentry.service`:

_(remember, `SENTRY_USER` is the user that you [made earlier in this guide](#12-add-the-non-root-sentry-user), when setting up Linux on the sentry node!)_

```
[Unit]
Description=Althea Sentry
After=network-online.target
StartLimitIntervalSec=0

[Service]
Type=simple
Restart=always
RestartSec=3
User=SENTRY_USER
TimeoutStopSec=90s
LimitNOFILE=65530
ExecStart=/usr/bin/althea start

[Install]
WantedBy=multi-user.target
```

Enable and start the new service:

```shell
sudo systemctl enable althea-sentry.service
sudo systemctl start althea-sentry.service
```

---

There you have it! 🎉 Don't forget to start your **validator** again, now that your sentry is up.

_If you have any questions, suggestions, or comments about this guide, please open a GitHub issue on this repo and share your thoughts._ 🙂
