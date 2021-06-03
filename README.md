# althea-systemd
systemd scripts for running an althea validator

## folder: `althea-scripts`
Place the scripts from the `althea-scripts` folder into the folder where you want to keep your althea scripts.

Maybe that's in `/home/altheauser/althea-scripts`, maybe it's `/etc/althea/scripts`, whatever. You decide. :)

## folder: `etc-systemd-system`
Place the scripts from the `etc-systemd-system` folder into `/etc/systemd/system/`, or wherever you keep your `systemd` scripts.

Then, run `sudo systemctl enable althea.service`, and do the same `sudo systemctl enable` for `geth.service` and `orchestrator-althea.service`