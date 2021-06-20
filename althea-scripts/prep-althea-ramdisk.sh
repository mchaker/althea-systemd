#!/bin/bash

rsync -av --mkpath --delete /home/altheauser/.althea-bkp/ /dev/shm/althea/
echo "[SUCCESS] Completed loading Althea state from cold storage --> RAM.";
