# How to set up an Althea Sentry node

_Adapted from [Paul Lovette](https://github.com/lightiv)'s [Linux Install guide](https://github.com/lightiv/SkyNet/wiki/Ubuntu-Linux-Install-Guide) and his [Akash Sentry setup guide](https://github.com/lightiv/SkyNet/wiki/Validator-Sentry-Setup-With-Best-Practice)_

## What is a Sentry node?
A Sentry node is a type of node that handles the traffic for a validator. As far as I understand, it helps manage the load on the overall network when other validators are joining.

# Part 1: Set up the Sentry host machine

_Note:_ The Sentry node must have its own IP address, and ideally be on a separate network (up/download line) from your other Sentries (ideally, geographically or globally distributed).

* The own IP address is a requirement because the Sentry node needs to exist separately on the network from your other sentries.
* The separate network is a requirement because that is what will help distribute the traffic/load on the Althea validator network.

It **may** be possible to run a **cluster** of sentries behind one IP address using **Kubernetes**, however I have not tried that yet.

## Step 1: Set up a new linux host

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

`sudo useradd USERNAME`

`sudo passwd USERNAME`

`usermod -aG sudo USERNAME`

Grant `sudo` permission scope to the new user:

`sudo visudo`

Add an entry for the new user under "User privilege specification":

`USERNAME    ALL=(ALL:ALL) ALL`

Add the new user's home directory and set the permissions on that directory:

`sudo mkdir /home/USERNAME/`

`sudo chown -R USERNAME:USERNAME /home/USERNAME/`

Set the new user's login shell to bash:

`chsh -s /bin/bash USERNAME`

### 1.3 Update and hardening

`sudo apt update`
`sudo apt dist-upgrade`
`sudo apt install -y unzip net-tools build-essential libssl-dev`

#### Configure the firewall (ufw, the "uncomplicated firewall")

Check if the firewall `ufw` is enabled: `sudo ufw status`

**IF the firewall is NOT enabled, continue with this "configure the firewall" section. Otherwise, continue to the next section, ["Part 2: Validator Sentry Setup"](#part-2-validator-sentry-setup).**

Disable the firewall at first, make modifications, then bring it back up.

So, first disable the firewall:

`sudo ufw disable`

Set the defaults for incoming/outgoing ports:

`sudo ufw default deny incoming`
`sudo ufw default allow outgoing`

Open up the SSH port:

`sudo ufw allow from any to any port 22 proto tcp`

Double-check the port you are opening for ssh is the same as what is set in `/etc/ssh/sshd_config`. You can change the ssh port in `/etc/ssh/sshd_config` if you like, just remember to open the port on the firewall as well.

Check the ssh port:

`cat /etc/ssh/sshd_config | grep Port`

Turn the firewall back on:

`sudo ufw enable`

`sudo ufw status verbose`

Make sure you see the ssh port in the allowed rules!

Finally, reboot: `sudo reboot`

# Part 2: Validator Sentry Setup
