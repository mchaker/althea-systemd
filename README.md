# althea-systemd
systemd scripts for running an althea validator

## folder: `althea-scripts`
Place the scripts from the `althea-scripts` folder into the folder where you want to keep your althea scripts.

Maybe that's in `/home/altheauser/althea-scripts`, maybe it's `/etc/althea/scripts`, whatever. You decide. :)

### Note about the `prep-` and `cleanup-` scripts
The scripts utilize `/dev/shm/` (an in-RAM folder aka shared memory aka `tmpfs`) to store the althea database and files **in memory (very fast, speedy bits)** while the althea service runs. As the althea service shuts down, the `/dev/shm/althea/` contents are backed up to disk.

If you don't want to load the althea database and files into memory, change the content of the `prep-` and `cleanup-` scripts. I might make the scripts take easily-changeable parameters in the future.

## folder: `etc-systemd-system`
Place the scripts from the `etc-systemd-system` folder into `/etc/systemd/system/`, or wherever you keep your `systemd` scripts.

Then, run `sudo systemctl enable althea.service`, and do the same `sudo systemctl enable` for `geth.service` and `orchestrator-althea.service`