ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
country=US
update_config=1

network={
 ssid="${SSID_NAME}"
 psk="${SSID_PASS}"
}