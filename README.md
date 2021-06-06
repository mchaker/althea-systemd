# althea-systemd
systemd scripts for running an althea validator

## First do this: [althea validator manual setup](https://github.com/althea-net/althea-chain/blob/main/docs/althea/althea-testnet-docs/setting-up-a-validator-manual.md)

## Compatibility note
* These scripts were developed on and tested on one of the most recent versions of Ubuntu Server (specifically Ubuntu Server 20.10).
* Read the scripts (they are short) and adjust the binary locations and folders to match your setup

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