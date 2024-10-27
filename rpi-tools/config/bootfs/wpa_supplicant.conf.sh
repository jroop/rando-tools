ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
country=US
update_config=1

network={
 ssid="${RPI_SSID_NAME}"
 psk="${RPI_SSID_PASS}"
}