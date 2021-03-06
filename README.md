# althea-systemd
systemd scripts for running an althea validator

## First do this: [althea validator manual setup](https://github.com/althea-net/althea-chain/blob/main/docs/althea/althea-testnet-docs/setting-up-a-validator-manual.md)

## Compatibility note
* These scripts were developed on and tested on one of the most recent versions of Ubuntu Server (specifically Ubuntu Server 20.10).
* Read the scripts (they are short) and adjust the binary locations and folders to match your setup
* ⚠️ If you want to use the high-speed `/dev/shm/` approach (currently the default way, with the prep/cleanup scripts) to running althea, you will need **48GB RAM (or more, 64GB+ seems safe)**. That is because the prep script loads the entire `.althea/` directory into RAM while running althea.
* You will need 50 GB storage _(the althea data folder is almost 15GB at time of writing, so to be safe as the network grows I recommend a linode 2GB plan or higher)_
* **storage latency should be < 5ms** (if you are not using the `/dev/shm/` shared memory approach)

ℹ️ Test storage latency with the `ioping` tool: `sudo ioping /dev/sdX -c5` where `/dev/sdX` is the device where your `.althea` data folder is mounted. Usually this is `/dev/sda`, but can be `/dev/mapper/ubuntu--vg-ubuntu--lv` on Ubuntu systems.

## `systemd` note about `/dev/shm/`
⚠️ **Important note:** In order to safely use `/dev/shm/`, you need to make the following edits to `/etc/systemd/logind.conf`:

Add the following line to `/etc/systemd/logind.conf`:

`RemoveIPC=no`

Save the file, then reboot the system. By default, `RemoveIPC` is `yes`, which means that periodically, `/dev/shm/` is cleaned up.

Since these scripts use `/dev/shm/` to keep the Althea data in memory while running (optional, of course, but enabled by default in these scripts), we don't want `/dev/shm/` to periodically clean up.

## folder: `althea-scripts`
Place the scripts from the `althea-scripts` folder into the folder where you want to keep your althea run scripts (not the systemd service files, those are separate).

Maybe that's in `/home/altheauser/althea-scripts`, maybe it's `/etc/althea/scripts`, whatever. You decide. :)

### Note about the `prep-` and `cleanup-` scripts
The scripts utilize `/dev/shm/` (an in-RAM folder aka shared memory aka `tmpfs`) to store the althea database and files **in memory (very fast, speedy bits)** while the althea service runs. As the althea service shuts down, the `/dev/shm/althea/` contents are backed up to disk.

If you don't want to load the althea database and files into memory, change the content of the `prep-` and `cleanup-` scripts. I might make the scripts take easily-changeable parameters in the future.

## folder: `etc-systemd-system`
Place the scripts from the `etc-systemd-system` folder into `/etc/systemd/system/`, or wherever you keep your `systemd` scripts.

Then, run `sudo systemctl enable althea.service`, and do the same `sudo systemctl enable` for `geth.service` and `orchestrator-althea.service`

After enabling the systemd services, run the following:

1. Start Althea: `sudo systemctl start althea.service`
1. Start Geth: `sudo systemctl start geth.service`
1. Start the Orchestrator: `sudo systemctl start orchestrator-althea.service`

You can check the status of all the services with: `sudo systemctl status althea.service geth.service orchestrator-althea.service` (all statuses for all 3 services will show up, navigate with the arrow keys, press `q` to quit the status view)
