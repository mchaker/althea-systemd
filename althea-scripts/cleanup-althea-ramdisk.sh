#!/bin/bash

rsync -av --mkpath --delete /dev/shm/althea/ /home/altheauser/.althea-bkp/
echo "[SUCCESS] Completed saving Althea state from RAM --> cold storage."
