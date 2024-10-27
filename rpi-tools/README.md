# rpi-tools

help create super simple headless setups on SD card before first boot.

## usage

```bash
# 1. create secrets.sh file
./setup.sh make-secrets

# 2. edit the file with desired settings

# 3. download and uncompress the image
./setup.sh download

# 4. find the mounted card
./setup.sh see-card

# 5. flash image to card
./setup.sh copy

# 6. ensure the config files match what was copied it may be different for 32 and 64 OS.
# look in config/boot & config/rootfs
# if different need to update the templates

# 7. create the new files want to update for the image
./setup.sh build
# then look at the files to see if they look okay

# 8. copy built files over
./setup.sh update-files

```
